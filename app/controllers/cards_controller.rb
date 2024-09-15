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
    @wallet = current_user.wallet
  end

  def set_card
    @card = @wallet.cards.find(params[:id])
  end

  def card_params
    params.require(:card).permit(
      :number,
      :name_printed,
      :expiration_month,
      :expiration_year,
      :cvv,
      :due_date,
      :limit)
  end

  def pay_success_message(amount)
    formatted_amount = format('%.2f', amount)
    "$#{formatted_amount} limit released on the card"
  end

end
