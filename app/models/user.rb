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

  has_many :business_cards, dependent: :destroy
  has_many :tags, dependent: :destroy
end
