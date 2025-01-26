class ChangeColumnNullOnSubscriptionDeliveryMethod < ActiveRecord::Migration[8.0]
  def change
    change_column_null :subscriptions, :delivery_method, true
  end
end
