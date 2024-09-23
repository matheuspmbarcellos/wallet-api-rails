require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:valid_attributes) { { user: { name: 'Test User', email: 'test@example.com', cpf: '12345678900', password: 'password' } } }
  let(:invalid_attributes) { { user: { name: '', email: 'test@example.com', cpf: '12345678900', password: '' } } }

  describe 'POST /users' do
    it 'creates a new user' do
      expect {
        post '/users', params: valid_attributes
      }.to change(User, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it 'does not create a user with invalid attributes' do
      post '/users', params: invalid_attributes
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'POST /login' do
    before { post '/users', params: valid_attributes }

    it 'logs in an existing user' do
      post '/login', params: { email: 'test@example.com', password: 'password' }
      expect(response).to have_http_status(:ok)
      token = JSON.parse(response.body)['token']
      expect(token).to be_present
    end

    it 'does not log in with invalid credentials' do
      post '/login', params: { email: 'test@example.com', password: 'wrong_password' }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to eq('Invalid email or password')
    end
  end

  describe 'GET /users/:id' do
    let(:user) { FactoryBot.create(:user) }
    let(:token) { JWT.encode({ user_id: user.id }, Rails.application.secret_key_base) }

    before { get "/users/#{user.id}", headers: { 'Authorization' => "Bearer #{token}" } }

    it 'returns the user' do
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['name']).to eq(user.name)
    end

    it 'returns unauthorized for another user' do
      # Create another user with unique attributes
      another_user = FactoryBot.create(:user, email: 'another@example.com', cpf: '12345678901')
      another_token = JWT.encode({ user_id: another_user.id }, Rails.application.secret_key_base)
      get "/users/#{user.id}", headers: { 'Authorization' => "Bearer #{another_token}" }
      expect(response).to have_http_status(:unauthorized)
    end
  end
  
  describe 'PATCH /users/:id' do
    let(:user) { FactoryBot.create(:user) }
    let(:token) { JWT.encode({ user_id: user.id }, Rails.application.secret_key_base) }
    let(:valid_attributes) { { user: { name: 'Updated Name' } } }
    let(:invalid_attributes) { { user: { name: '' } } }
  
    context 'when the user is authorized' do
      before { patch "/users/#{user.id}", params: valid_attributes, headers: { 'Authorization' => "Bearer #{token}" } }
  
      it 'updates the user' do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('User updated successfully')
        expect(JSON.parse(response.body)['user_updated']['name']).to eq('Updated Name')
      end
  
      it 'does not update with invalid attributes' do
        patch "/users/#{user.id}", params: invalid_attributes, headers: { 'Authorization' => "Bearer #{token}" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('name')
      end
    end
  
    context 'when the user is unauthorized' do
      let(:another_user) { FactoryBot.create(:user, email: 'another@example.com', cpf: '12345678901') }
      let(:another_token) { JWT.encode({ user_id: another_user.id }, Rails.application.secret_key_base) }
  
      before { patch "/users/#{user.id}", params: valid_attributes, headers: { 'Authorization' => "Bearer #{another_token}" } }
  
      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
      end
    end
  end
  
  
end
