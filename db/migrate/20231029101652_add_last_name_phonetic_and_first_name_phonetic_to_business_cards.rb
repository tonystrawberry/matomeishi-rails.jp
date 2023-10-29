class AddLastNamePhoneticAndFirstNamePhoneticToBusinessCards < ActiveRecord::Migration[7.0]
  def change
    add_column :business_cards, :last_name_phonetic, :string
    add_column :business_cards, :first_name_phonetic, :string
  end
end
