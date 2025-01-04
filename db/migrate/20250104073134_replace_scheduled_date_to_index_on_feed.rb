class ReplaceScheduledDateToIndexOnFeed < ActiveRecord::Migration[8.0]
  def change
    remove_column :feeds, :scheduled_date, :date
    add_column :feeds, :position, :integer, null: false
    add_index :feeds, [:campaign_id, :position], unique: true

    # position >= 1 の制約を追加
    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE feeds ADD CONSTRAINT check_position_greater_than_zero
          CHECK (position >= 1)
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE feeds DROP CONSTRAINT check_position_greater_than_zero
        SQL
      end
    end
  end
end