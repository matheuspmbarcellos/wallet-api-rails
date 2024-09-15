class ApplicationController < ActionController::API
  before_action :authorize_request

  def current_user
    @current_user ||= User.find(decoded_token[:user_id]) if decoded_token
  end

  private

  def authorize_request
    render json: { error: 'Not Authorized' }, status: :unauthorized unless current_user
  end

  def decoded_token
    if auth_header
      token = auth_header.split(' ').last
      begin
        JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256')[0]
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def auth_header
    request.headers['Authorization']
  end

end
