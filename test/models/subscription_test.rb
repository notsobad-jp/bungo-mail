require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  def setup
    @user_basic_with_fcm = User.new(plan: :basic, fcm_device_token: 'some_token')
    @user_basic_without_fcm = User.new(plan: :basic, fcm_device_token: nil)
    @user_free_with_fcm = User.new(plan: :free, fcm_device_token: 'some_token')
    @user_free_without_fcm = User.new(plan: :free, fcm_device_token: nil)
  end

  test "enabled_delivery_methods for user with basic plan and FCM token" do
    assert_equal [:email, :webpush], Subscription.enabled_delivery_methods(@user_basic_with_fcm)
  end

  test "enabled_delivery_methods for user with basic plan and no FCM token" do
    assert_equal [:email], Subscription.enabled_delivery_methods(@user_basic_without_fcm)
  end

  test "enabled_delivery_methods for user with free plan and FCM token" do
    assert_equal [:webpush], Subscription.enabled_delivery_methods(@user_free_with_fcm)
  end

  test "enabled_delivery_methods for user with free plan and no FCM token" do
    assert_equal [], Subscription.enabled_delivery_methods(@user_free_without_fcm)
  end
end
