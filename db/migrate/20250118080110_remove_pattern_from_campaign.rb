class RemovePatternFromCampaign < ActiveRecord::Migration[8.0]
  def change
    remove_column :campaigns, :pattern, :string, null: false, default: "seigaiha"
  end
end
