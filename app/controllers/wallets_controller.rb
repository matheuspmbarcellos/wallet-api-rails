class WalletsController < ApplicationController
  before_action :set_wallet

  def show
    render json: @wallet
  end

  def set_custom_limit
    custom_limit = safe_to_bigdecimal(params[:custom_limit])
    if custom_limit && @wallet.update_custom_limit(custom_limit)
      render json: @wallet, status: :ok
    else
      render json: @wallet.errors, status: :unprocessable_entity
    end
  end

  def spend
    amount = safe_to_bigdecimal(params[:amount])
    if amount && @wallet.make_purchase(amount)
      render json: {message: purchase_success_message(amount)}, status: :ok
    else
      render json: @wallet.errors, status: :unprocessable_entity
    end
  end

  private

  def set_wallet
    unless current_user
      render json: { error: 'User not authenticated' }, status: :unauthorized and return
    end 

    user = User.find_by(id: params[:user_id])
    if user.nil? || user.id != current_user.id
      render json: { error: 'User not authenticated' }, status: :unauthorized and return
    end
    
    @wallet = Wallet.find_by(id: params[:id])
    if @wallet.nil? || @wallet.user_id != current_user.id || @wallet.id != current_user.wallet.id
      render json: { error: 'Wallet not found' }, status: :not_found and return
    end    
  end  

  def purchase_success_message(amount)
    formatted_amount = format('%.2f', amount)
    available_credit = format('%.2f', @wallet.credit_available)
    "Purchase of $#{formatted_amount} approved. Wallet now has available credit of $#{available_credit}"
  end

  def safe_to_bigdecimal(value)
    BigDecimal(value.to_s)
  rescue ArgumentError, TypeError
    nil
  end
  
end
