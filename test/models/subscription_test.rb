require 'test_helper'

describe Subscription do
  describe "delivery_method" do
    it "should allow :email for basic plan users" do
      user = users(:basic)
      campaign = campaigns(:one)
      sub = Subscription.new(user: user, campaign: campaign, delivery_method: :email)
      assert sub.valid?
    end

    it "should not allow :email for free plan users" do
      user = users(:free)
      campaign = campaigns(:one)
      sub = Subscription.new(user: user, campaign: campaign, delivery_method: :email)
      refute sub.valid?
    end
  end

  describe "enabled_delivery_methods" do
    context "user with free plan" do
      context "with FCM token" do
        it "should return [:webpush]" do
          user = users(:free_with_fcm)
          sub = Subscription.new(user: user)
          assert_equal [:webpush], sub.enabled_delivery_methods
        end
      end

      context "without FCM token" do
        it "should return []" do
          user = users(:free)
          sub = Subscription.new(user: user)
          assert_equal [], sub.enabled_delivery_methods
        end
      end
    end

    context "user with basic plan" do
      context "with FCM token" do
        it "should return [:email, :webpush]" do
          user = users(:basic_with_fcm)
          sub = Subscription.new(user: user)
          assert_equal [:email, :webpush], sub.enabled_delivery_methods
        end
      end

      context "without FCM token" do
        it "should return [:email]" do
          user = users(:basic)
          sub = Subscription.new(user: user)
          assert_equal [:email], sub.enabled_delivery_methods
        end
      end
    end
  end
end
