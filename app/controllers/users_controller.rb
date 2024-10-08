class UsersController < ApplicationController
  skip_before_action :authorize_request, only: [:create, :login]

  def show
    if current_user.id != params[:id].to_i
      render json: { error: 'Unauthorized' }, status: :unauthorized and return
    end
  
    render json: current_user.as_json(except: [:password_digest])
  end

  def create
    @user = User.new(users_params)
    if @user.save
      token = encode_token(user_id: @user.id)
      render json: { token: token, message: 'User created successfully' }, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end    
  end 

  def update
    if current_user.id != params[:id].to_i
      render json: { error: 'Unauthorized' }, status: :unauthorized and return
    end
  
    if current_user.update(users_params)
      render json: {
        "message":"User updated successfully", 
        "user_updated":current_user.as_json(except: [:password_digest])
        }, status: :ok
    else
      render json: current_user.errors, status: :unprocessable_entity
    end   
  end
  

  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = encode_token(user_id: user.id)
      render json: { token: token }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end
  
  private

  def encode_token(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end

  def users_params
    params.require(:user).permit(:cpf, :name, :email, :password)
  end
  
end
