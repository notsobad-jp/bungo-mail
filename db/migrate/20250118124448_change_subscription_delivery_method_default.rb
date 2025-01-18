class ChangeSubscriptionDeliveryMethodDefault < ActiveRecord::Migration[8.0]
  def change
    change_column_default :subscriptions, :delivery_method, from: "email", to: nil
  end
end
