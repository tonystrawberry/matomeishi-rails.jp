# frozen_string_literal: true

##
## CreateBusinessCards migration
##
class CreateBusinessCards < ActiveRecord::Migration[7.0]
  def change
    create_table :business_cards do |t|
      t.references :user, null: false, foreign_key: true

      t.string :last_name, limit: 100
      t.string :first_name, limit: 100
      t.string :company, limit: 100
      t.string :email, limit: 100
      t.integer :status, null: false, default: 0
      t.string :code, null: false, limit: 100
      t.string :mobile_phone, limit: 100
      t.string :home_phone, limit: 100
      t.string :fax, limit: 100
      t.datetime :meeting_date
      t.text :notes

      t.timestamps
    end

    add_index :business_cards, :code, unique: true
  end
end
