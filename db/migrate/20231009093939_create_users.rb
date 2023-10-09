# frozen_string_literal: true

##
## CreateUsers migration
##
class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name, null: false, limit: 100
      t.string :email, null: false
      t.string :uid, null: false
      t.string :provider, null: false

      t.timestamps
    end
  end
end
