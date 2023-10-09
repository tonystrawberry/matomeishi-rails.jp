# frozen_string_literal: true

##
## CreateBusinessCards migration
##
class CreateBusinessCards < ActiveRecord::Migration[7.0]
  def change
    create_table :business_cards do |t|
      t.references :user, null: false, foreign_key: true

      t.string :name, null: false, limit: 100
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
