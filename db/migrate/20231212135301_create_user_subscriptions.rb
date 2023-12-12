class CreateUserSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :user_subscriptions do |t|
      t.references :user_billing, null: false, foreign_key: true

      t.string :subscription_id
      t.datetime :term_from
      t.datetime :term_to
      t.integer :plan_type
      t.string :status
      t.float :price
      t.boolean :cancel_at_period_end, default: false
      t.string :payment_intent_status
      t.integer :will_downgrade_to

      t.timestamps
    end

    add_index :user_subscriptions, :subscription_id, unique: true
  end
end
