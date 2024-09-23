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
    if @card.current_spent_amount == 0
      @card.destroy!
      head :no_content
    else
      render json: { error: 'The card cannot be deleted because there is a bill to be paid.' }, status: :unprocessable_entity
    end
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
    @wallet = current_user.wallet
    if @wallet.nil? || @wallet.id != params[:wallet_id].to_i
      render json: { error: 'Wallet not found' }, status: :not_found and return
    end
  end
  

  def set_card
    @card = @wallet.cards.find_by(id: params[:id])
    unless @card
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
