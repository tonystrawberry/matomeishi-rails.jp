# frozen_string_literal: true

class CreateBusinessCardTags < ActiveRecord::Migration[7.0]
  def change
    create_table :business_card_tags do |t|
      t.references :business_card, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
