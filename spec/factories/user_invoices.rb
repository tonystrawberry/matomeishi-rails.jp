# == Schema Information
#
# Table name: user_invoices
#
#  id                   :bigint           not null, primary key
#  invoice_pdf          :string
#  paid_at              :datetime
#  plan_type            :integer
#  stripe_status        :string
#  term_from            :datetime
#  term_to              :datetime
#  total                :float
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  stripe_invoice_id    :string
#  user_billing_id      :bigint           not null
#  user_subscription_id :bigint           not null
#
# Indexes
#
#  index_user_invoices_on_stripe_invoice_id     (stripe_invoice_id) UNIQUE
#  index_user_invoices_on_user_billing_id       (user_billing_id)
#  index_user_invoices_on_user_subscription_id  (user_subscription_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_billing_id => user_billings.id)
#  fk_rails_...  (user_subscription_id => user_subscriptions.id)
#
FactoryBot.define do
  factory :user_invoice do
    
  end
end
