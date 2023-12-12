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
class UserInvoice < ApplicationRecord
  belongs_to :user_billing
  belongs_to :user_subscription

  enum plan_type: { pro: 0, unlimited: 1 }, _prefix: true

  STRIPE_PRICE_IDS = {
    pro: 'price_1OMVlsHar31BZeHdTk89gPZs',
    unlimited: 'price_1OMVmkHar31BZeHdzlW9fyFE'
  }.freeze

  ## Update the user invoice based on the invoice object
  # Reference: https://stripe.com/docs/api/invoices/object
  def self.update_invoice_via_webhook_event(event)
    invoice = JSON.parse(event.data.object.to_json)
    line = invoice['lines']['data'].find { |d| (d['amount']).positive? }

    user_billing = UserBilling.find_by!(stripe_customer_id: invoice['customer'])
    user_subscription = UserSubscription.find_by!(subscription_id: invoice['subscription'])

    user_invoice = UserInvoice.where(stripe_invoice_id: invoice['id']).first_or_initialize

    attributes = {
      user_billing_id: user_billing.id,
      user_subscription_id: user_subscription.id,
      plan_type: STRIPE_PRICE_IDS.key(line['plan']['id']),
      stripe_status: invoice['status'],
      total: invoice['total'],
      term_from: Time.zone.strptime(line['period']['start'].to_s, '%s'),
      term_to: Time.zone.strptime(line['period']['end'].to_s, '%s'),
      invoice_pdf: invoice['invoice_pdf'],
      paid_at: invoice['status_transitions']['paid_at']
    }

    user_invoice.attributes = attributes
    user_invoice.save!
  end
end
