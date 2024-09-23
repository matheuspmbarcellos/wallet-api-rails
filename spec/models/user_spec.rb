require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }
  it { should validate_presence_of(:cpf) }
  it { should validate_uniqueness_of(:cpf) }

  it 'creates a wallet after user creation' do
    user = FactoryBot.create(:user)
    expect(user.wallet).to be_present
  end

  describe 'password encryption' do
    it 'encrypts the password' do
      user = FactoryBot.build(:user, password: 'password')
      expect(user.password_digest).to be_present
    end
  end
end
