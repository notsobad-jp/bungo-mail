require 'test_helper'

describe Subscription do
  describe "enabled_delivery_methods" do
    context "user with free plan" do
      context "with FCM token" do
        it "should return [:webpush]" do
          user_free_with_fcm = User.new(plan: :free, fcm_device_token: 'some_token')
          assert_equal [:webpush], Subscription.enabled_delivery_methods(user_free_with_fcm)
        end
      end

      context "without FCM token" do
        it "should return []" do
          user_free_without_fcm = User.new(plan: :free)
          assert_equal [], Subscription.enabled_delivery_methods(user_free_without_fcm)
        end
      end
    end

    context "user with basic plan" do
      context "with FCM token" do
        it "should return [:email, :webpush]" do
          user_basic_with_fcm = User.new(plan: :basic, fcm_device_token: 'some_token')
          assert_equal [:email, :webpush], Subscription.enabled_delivery_methods(user_basic_with_fcm)
        end
      end

      context "without FCM token" do
        it "should return [:email]" do
          user_basic_without_fcm = User.new(plan: :basic)
          assert_equal [:email], Subscription.enabled_delivery_methods(user_basic_without_fcm)
        end
      end
    end
  end
end
