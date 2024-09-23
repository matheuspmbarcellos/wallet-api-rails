class WalletsController < ApplicationController
  before_action :set_wallet

  def show
    render json: @wallet.as_json.merge(credit_available: @wallet.credit_available), status: :ok
  end

  def limit
    custom_limit = safe_to_bigdecimal(params[:custom_limit])
    if custom_limit && @wallet.update_custom_limit(custom_limit)
      render json: @wallet.as_json.merge(new_credit_available: @wallet.credit_available), status: :ok
    else
      render json: @wallet.errors, status: :unprocessable_entity
    end
  end

  def purchase
    amount = safe_to_bigdecimal(params[:amount])
    if amount && @wallet.make_purchase(amount)
      render json: {message: purchase_success_message(amount)}, status: :ok
    else
      render json: @wallet.errors, status: :unprocessable_entity
    end
  end

  private

  def set_wallet
    @wallet = current_user.wallet
    if @wallet.nil? || @wallet.id != params[:id].to_i
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
