# frozen_string_literal: true

##
## Api::V1::SubscriptionsController
## Api::V1::SubscriptionsController is a controller for subscriptions
##
class Api::V1::SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  ## POST /api/v1/subscriptions
  ## Create a subscription for the current user
  def create_subscription
    param!(:price_id, String, required: true)

    stripe_customer_id = current_user.user_billing.stripe_customer_id

    subscription = Stripe::Subscription.create(
      customer: stripe_customer_id,
      items: [{ price: params[:price_id] }],
      payment_behavior: 'default_incomplete',
      payment_settings: { save_default_payment_method: 'on_subscription' },
      expand: ['latest_invoice.payment_intent', 'pending_setup_intent']
    )

    if subscription.pending_setup_intent.present?
      render json: { type: 'setup', client_secret: subscription.pending_setup_intent.client_secret }, status: :ok
    else
      render json: { type: 'payment', client_secret: subscription.latest_invoice.payment_intent.client_secret }, status: :ok
    end
  end


  ## POST /api/v1/subscriptions/payment_intent
  ## Create a payment intent for the subscription
  def payment_intent
    param!(:subscription_id, String)

    payment_intent = Stripe::PaymentIntent.create(
      amount: calculate_order_amount(data['items']),
      currency: 'jpy',
      # In the latest version of the API, specifying the `automatic_payment_methods` parameter is optional because Stripe enables its functionality by default.
      automatic_payment_methods: {
        enabled: true,
      },
    )

    render json: { client_secret: payment_intent.client_secret }, status: :ok
  end
end
