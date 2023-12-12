# == Schema Information
#
# Table name: user_billings
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  stripe_customer_id :string           not null
#  user_id            :bigint           not null
#
# Indexes
#
#  index_user_billings_on_stripe_customer_id  (stripe_customer_id) UNIQUE
#  index_user_billings_on_user_id             (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :user_billing do
    
  end
end
