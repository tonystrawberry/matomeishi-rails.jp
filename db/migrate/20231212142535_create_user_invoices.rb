class CreateUserInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :user_invoices do |t|
      t.references :user_billing, null: false, foreign_key: true
      t.references :user_subscription, null: false, foreign_key: true

      t.float :total
      t.string :stripe_invoice_id
      t.datetime :term_from
      t.datetime :term_to
      t.string :stripe_status
      t.string :invoice_pdf
      t.datetime :paid_at
      t.integer :plan_type

      t.timestamps
    end

    add_index :user_invoices, :stripe_invoice_id, unique: true
  end
end
