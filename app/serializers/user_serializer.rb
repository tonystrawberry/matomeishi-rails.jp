# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  email      :string           not null
#  name       :string(100)      not null
#  provider   :string           not null
#  uid        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class UserSerializer
  include JSONAPI::Serializer

  set_type :user
  attributes :name, :email, :uid, :provider
end
