class CreateUserBillings < ActiveRecord::Migration[7.0]
  def change
    create_table :user_billings do |t|
      t.references :user, null: false, foreign_key: true
      t.string :stripe_customer_id, null: false

      t.timestamps
    end

    add_index :user_billings, :stripe_customer_id, unique: true
  end
end
