class CardsController < ApplicationController
  before_action :set_wallet
  before_action :set_card, only: [:show, :destroy, :pay]

  def index
    render json: @wallet.cards
  end

  def show
    render json: @card
  end

  def create
    @card = @wallet.cards.new(card_params)

    if @card.save
      render json: @card.as_json(except: [:cvv]), status: :created
    else
      render json: @card.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @card.destroy!
    head :no_content
  rescue ActiveRecord::RecordNotDestroyed
    render json: @card.errors, status: :unprocessable_entity
  end

  def pay
    amount = safe_to_bigdecimal(params[:amount])
    if amount && @card.pay(amount)
      render json: {message: pay_success_message(amount)}, status: :ok
    else
      render json: @card.errors, status: :unprocessable_entity
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
    
    @wallet = Wallet.find_by(id: params[:wallet_id])
    if @wallet.nil? || @wallet.user_id != current_user.id || @wallet.id != current_user.wallet.id
      render json: { error: 'Wallet not found' }, status: :not_found and return
    end    
  end

  def set_card
    @card = @wallet.cards.find_by(id: params[:id])
    if @card.nil?
      render json: { error: 'Card not found' }, status: :not_found
    end
  end

  def card_params
    params.require(:card).permit(
      :number,
      :name_printed,
      :expiration_month,
      :expiration_year,
      :cvv,
      :due_date,
      :card_limit)
  end

  def pay_success_message(amount)
    formatted_amount = format('%.2f', amount)
    "$#{formatted_amount} limit released on the card"
  end

  def safe_to_bigdecimal(value)
    BigDecimal(value.to_s)
  rescue ArgumentError, TypeError
    nil
  end

end
