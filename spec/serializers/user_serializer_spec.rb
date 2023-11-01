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
RSpec.describe UserSerializer do
  describe 'attributes' do
    subject { described_class.new(user).serializable_hash[:data][:attributes] }

    let(:user) { build(:user) }

    it { is_expected.to include(name: user.name) }
    it { is_expected.to include(email: user.email) }
    it { is_expected.to include(uid: user.uid) }
    it { is_expected.to include(providers: user.providers) }
  end
end
