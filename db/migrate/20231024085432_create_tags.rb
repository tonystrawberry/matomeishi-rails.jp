# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[7.0]
  def change
    create_table :tags do |t|
      t.references :user, null: false, foreign_key: true

      t.string :name, limit: 100, null: false
      t.text :description, limit: 1000
      t.string :color, limit: 7, null: false
      t.integer :business_cards_count, null: false, default: 0

      t.timestamps
    end
  end
end
