# == Schema Information
#
# Table name: user_subscriptions
#
#  id                    :bigint           not null, primary key
#  cancel_at_period_end  :boolean          default(FALSE)
#  payment_intent_status :string
#  plan_type             :integer
#  price                 :float
#  status                :string
#  term_from             :datetime
#  term_to               :datetime
#  will_downgrade_to     :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  subscription_id       :string
#  user_billing_id       :bigint           not null
#
# Indexes
#
#  index_user_subscriptions_on_subscription_id  (subscription_id) UNIQUE
#  index_user_subscriptions_on_user_billing_id  (user_billing_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_billing_id => user_billings.id)
#
class UserSubscription < ApplicationRecord
  belongs_to :user_billing

  enum plan_type: { free: 0, pro: 1, unlimited: 2 }, _prefix: true
  enum will_downgrade_to: { free: 0, pro: 1, unlimited: 2 }, _prefix: true

  STRIPE_PRICE_IDS = {
    pro: 'price_1OMVlsHar31BZeHdTk89gPZs',
    unlimited: 'price_1OMVmkHar31BZeHdzlW9fyFE'
  }.freeze

  STRIPE_PRODUCT_IDS = {
    pro: 'prod_PArUEIB5hBD9aD',
    unlimited: 'prod_PArVS3AjEegQNB'
  }.freeze

  #####################
  ### Class Methods ###
  #####################

  ## Update the user subscription based on the webhook event
  # Reference: https://stripe.com/docs/api/subscriptions/object
  def self.update_subscription_via_webhook_event(event)
    subscription = event.data.object

    user_subscription = UserSubscription.find_by(subscription_id: subscription.id)

    # If the subscription is not found, it means that the subscription was created
    if user_subscription.nil?
      user_billing = UserBilling.find_by!(stripe_customer_id: subscription.customer)
      user_subscription = UserSubscription.new(user_billing_id: user_billing.id, subscription_id: subscription.id)
    end

    user_subscription.update_by_subscription_object(JSON.parse(subscription.to_json))
  end

  ########################
  ### Instance Methods ###
  ########################

  ## Update the user subscription based on the subscription object
  # Reference: https://stripe.com/docs/api/subscriptions/object
  def update_by_subscription_object(subscription)
    plan_type = STRIPE_PRODUCT_IDS.key(subscription['plan']['product'])
    invoice = Stripe::Invoice.retrieve({ id: subscription['latest_invoice'], expand: %w[payment_intent] })
    will_downgrade_to_plan_type = nil
    subscription_schedule = Stripe::SubscriptionSchedule.retrieve(subscription['schedule']) if subscription['schedule'].present?

    if subscription_schedule.present? && subscription_schedule.status == 'active'
      # schedule is present -> must be a subscription downgrade
      price_id = subscription_schedule.phases.last.items.last.price
      last_phase_plan_type = STRIPE_PRICE_IDS.key(price_id)
      will_downgrade_to_plan_type = STRIPE_PRICE_IDS.key(price_id) if last_phase_plan_type != self.plan_type && last_phase_plan_type == 'pro'
    end

    attributes = {
      subscription_id: subscription['id'],
      price: subscription['plan']['amount'],
      term_from: Time.zone.strptime(subscription['current_period_start'].to_s, '%s'),
      term_to: Time.zone.strptime(subscription['current_period_end'].to_s, '%s'),
      status: subscription['status'],
      plan_type: plan_type,
      cancel_at_period_end: subscription['cancel_at_period_end'],
      will_downgrade_to: will_downgrade_to_plan_type,
      payment_intent_status: invoice['payment_intent']['status'].presence
    }

    self.attributes = attributes

    save!
  end

  # Cancel a subscription by canceling
  # the subscription on Stripe and then by updating the
  # database record with the returned subscription object from Stripe
  # Reference: https://stripe.com/docs/api/subscriptions/cancel
  def cancel_subscription
    subscription = Stripe::Subscription.retrieve(subscription_id)

    subscription_schedule_id = subscription.schedule
    Stripe::SubscriptionSchedule.release(subscription_schedule_id) if subscription_schedule_id.present?

    subscription = Stripe::Subscription.update(subscription_id, { cancel_at_period_end: true })

    update_by_subscription_object(subscription)
  end

  # Reactivate a subscription that was cancelled previously
  # That will cancel the subscription cancellation
  # Reference: https://stripe.com/docs/api/subscriptions/update
  def reactivate_subscription
    subscription = Stripe::Subscription.update(subscription_id, { cancel_at_period_end: false })

    update_by_subscription_object(subscription)
  end

  # Change the plan for the current subscription
  # Reference: https://stripe.com/docs/billing/subscriptions/upgrade-downgrade
  def change_plan(target_plan_type:)
    subscription = Stripe::Subscription.retrieve(subscription_id)

    # Get the price IDs for the current plan and the target plan
    from_price_id = STRIPE_PRICE_IDS[plan_type.to_sym]
    to_price_id = STRIPE_PRICE_IDS[target_plan_type.to_sym]

    case target_plan_type
    when 'pro'
      subscription_schedule_id = subscription.schedule

      # If there is no subscription schedule, create a new one
      # Otherwise, update the existing one
      if subscription_schedule_id.nil?
        subscription_schedule = Stripe::SubscriptionSchedule.create({ from_subscription: subscription_id })

        # Create a new subscription schedule
        # Plan the downgrade starting from the next billing cycle
        Stripe::SubscriptionSchedule.update(subscription_schedule.id,
          {
            phases: [{
              items: [{ price: from_price_id }],
              start_date: term_from.to_i,
              end_date: term_to.to_i
            },{
              items: [{ price: to_price_id }],
              start_date: term_to.to_i
            }],
            end_behavior: 'release'
          }
        )
      else
        # Update the existing subscription schedule
        # Plan the downgrade starting from the next billing cycle
        Stripe::SubscriptionSchedule.update(subscription_schedule_id,
          {
            phases: [{
              items: [{ price: from_price_id }],
              start_date: term_from.to_i,
              end_date: term_to.to_i
            },{
              items: [{ price: to_price_id }],
              start_date: term_to.to_i
            }],
            end_behavior: 'release'
          }
        )
      end

      update!(will_downgrade_to: target_plan_type)
    when 'unlimited'
      # Update the subscription directly
      # and upgrade the subscription immediately
      subscription = Stripe::Subscription.update(subscription_id,
        {
          cancel_at_period_end: false,
          proration_behavior: 'create_prorations',
          items: [{ id: subscription.items.data[0].id, price: to_price_id }]
        }
      )

      update_by_subscription_object(subscription)
    end
  end

  # Cancel the downgrade for the current subscription
  # Reference: https://stripe.com/docs/billing/subscriptions/upgrade-downgrade
  def cancel_downgrade
    subscription = Stripe::Subscription.retrieve(subscription_id)
    subscription_schedule_id = subscription.schedule

    Stripe::SubscriptionSchedule.release(subscription_schedule_id) if subscription_schedule_id.present?

    update_by_subscription_object(subscription)
  end
end
