class UserSubscriptionSerializer
  include JSONAPI::Serializer

  attributes :id,
              :cancel_at_period_end,
              :payment_intent_status,
              :plan_type,
              :price,
              :status,
              :term_from,
              :term_to,
              :will_downgrade_to,
              :subscription_id,
              :user_billing_id
end
