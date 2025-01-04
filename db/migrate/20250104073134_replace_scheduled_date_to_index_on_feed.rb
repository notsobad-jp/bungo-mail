class ReplaceScheduledDateToIndexOnFeed < ActiveRecord::Migration[8.0]
  def change
    remove_column :feeds, :delivery_date, :date
    add_column :feeds, :position, :integer, null: false
    add_index :feeds, [:campaign_id, :position], unique: true
  end
end
