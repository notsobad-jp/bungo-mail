class AddStartAtAndEndAtToCampaign < ActiveRecord::Migration[8.0]
  def change
    add_column :campaigns, :start_at, :virtual, type: :datetime, as: "start_date + delivery_time", stored: true
    add_column :campaigns, :end_at, :virtual, type: :datetime, as: "end_date + delivery_time", stored: true
  end
end
