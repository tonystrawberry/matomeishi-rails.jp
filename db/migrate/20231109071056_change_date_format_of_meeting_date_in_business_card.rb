class ChangeDateFormatOfMeetingDateInBusinessCard < ActiveRecord::Migration[7.0]
  def change
    change_column :business_cards, :meeting_date, :date
  end
end
