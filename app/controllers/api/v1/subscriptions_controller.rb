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

  ## GET /api/v1/subscriptions/current
  ## Get the current subscription for the current user
  def current
    user_subscription = current_user.user_billing.user_subscriptions.find_by(status: 'active')

    if user_subscription.present?
      render json: UserSubscriptionSerializer.new(user_subscription).serializable_hash, status: :ok
    else
      render json: {}
    end
  end

  ## POST /api/v1/subscriptions/cancel
  ## Cancel the current subscription for the current user
  def cancel_subscription
    param!(:subscription_id, String, required: true)

    user_subscription = UserSubscription.find_by!(subscription_id: params[:subscription_id])
    user_subscription.cancel_subscription

    render json: UserSubscriptionSerializer.new(user_subscription).serializable_hash, status: :ok
  end

  ## POST /api/v1/subscriptions/reactivate
  ## Reactivate the current subscription for the current user
  def reactivate_subscription
    param!(:subscription_id, String, required: true)

    user_subscription = UserSubscription.find_by!(subscription_id: params[:subscription_id])
    user_subscription.reactivate_subscription

    render json: UserSubscriptionSerializer.new(user_subscription).serializable_hash, status: :ok
  end

  ## POST /api/v1/subscriptions/change_plan
  ## Change the plan for the current subscription for the current user
  def change_plan
    param!(:plan_type, String, required: true)
    param!(:subscription_id, String, required: true)

    user_subscription = UserSubscription.find_by!(subscription_id: params[:subscription_id])
    user_subscription.change_plan(target_plan_type: params[:plan_type])

    render json: UserSubscriptionSerializer.new(user_subscription).serializable_hash, status: :ok
  end

  ## POST /api/v1/subscriptions/cancel_downgrade
  ## Cancel the downgrade for the current subscription for the current user
  def cancel_downgrade
    param!(:subscription_id, String, required: true)

    user_subscription = UserSubscription.find_by!(subscription_id: params[:subscription_id])
    user_subscription.cancel_downgrade

    render json: UserSubscriptionSerializer.new(user_subscription).serializable_hash, status: :ok
  end
end
