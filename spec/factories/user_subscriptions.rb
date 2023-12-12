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
FactoryBot.define do
  factory :user_subscription do
    
  end
end
