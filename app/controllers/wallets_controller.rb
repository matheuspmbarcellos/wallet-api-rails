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
    if amount && @wallet.spend(amount)
      render json: {message: purchase_success_message(amount)}, status: :ok
    else
      render json: @wallet.errors, status: :unprocessable_entity
    end
  end

  private

  def set_wallet
    @wallet = current_user.wallet
  end

  def purchase_success_message(amount)
    formatted_amount = format('%.2f', amount)
    available_credit = format('%.2f', @wallet.credit_available)
    "Purchase of $#{formatted_amount} approved. Wallet now has available credit of $#{available_credit}"
  end
  
end
