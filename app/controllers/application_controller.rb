class ApplicationController < ActionController::API
  before_action :authorize_request

  def current_user
    decoded_hash = decoded_token
    if decoded_hash && decoded_hash['user_id']
      @current_user ||= User.find_by(id: decoded_hash['user_id'])
    end
  end

  private

  def authorize_request
    render json: { error: 'Not Authorized' }, status: :unauthorized unless current_user
  end

  def decoded_token
    if auth_header
      token = auth_header.split(' ').last
      begin
        JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256').first
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def auth_header
    request.headers['Authorization']
  end

end
