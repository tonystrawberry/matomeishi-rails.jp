# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  email      :string           not null
#  name       :string(100)
#  providers  :string           default([]), not null, is an Array
#  uid        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#  index_users_on_uid    (uid) UNIQUE
#

##
## User model representing a user of the application
## Authentication is handled by Firebase
##
class User < ApplicationRecord
  validates :name, length: { maximum: 100 }
  validates :email, presence: true
  validates :uid, presence: true
  validates :providers, presence: true

  has_one :user_billing, dependent: :destroy

  has_many :business_cards, dependent: :destroy
  has_many :tags, dependent: :destroy

  after_create :create_stripe_customer

  ## Create a Stripe customer for the user and save the Stripe customer ID
  # Called on `after_create` callback
  def create_stripe_customer
    stripe_customer = Stripe::Customer.create({
      email: email,
      name: name
    })

    user_billing = UserBilling.create!(
      user: self,
      stripe_customer_id: stripe_customer.id
    )
  end
end
