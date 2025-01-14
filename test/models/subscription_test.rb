require 'test_helper'

describe Subscription do
  describe "delivery_method" do
    it "should allow :email for basic plan users" do
      user = User.new(plan: :basic)
      sub = Subscription.new(campaign: Campaign.new, delivery_method: :email, user: user)
      assert sub.valid?
    end

    it "should not allow :email for free plan users" do
      user = User.new(plan: :free)
      sub = Subscription.new(delivery_method: :email, user: user)
      refute sub.valid?
    end
  end

  describe "enabled_delivery_methods" do
    context "user with free plan" do
      context "with FCM token" do
        it "should return [:webpush]" do
          user_free_with_fcm = User.new(plan: :free, fcm_device_token: 'some_token')
          subscription = Subscription.new(user: user_free_with_fcm)
          assert_equal [:webpush], subscription.enabled_delivery_methods
        end
      end

      context "without FCM token" do
        it "should return []" do
          user_free_without_fcm = User.new(plan: :free)
          subscription = Subscription.new(user: user_free_without_fcm)
          assert_equal [], subscription.enabled_delivery_methods
        end
      end
    end

    context "user with basic plan" do
      context "with FCM token" do
        it "should return [:email, :webpush]" do
          user_basic_with_fcm = User.new(plan: :basic, fcm_device_token: 'some_token')
          subscription = Subscription.new(user: user_basic_with_fcm)
          assert_equal [:email, :webpush], subscription.enabled_delivery_methods
        end
      end

      context "without FCM token" do
        it "should return [:email]" do
          user_basic_without_fcm = User.new(plan: :basic)
          subscription = Subscription.new(user: user_basic_without_fcm)
          assert_equal [:email], subscription.enabled_delivery_methods
        end
      end
    end
  end
end
