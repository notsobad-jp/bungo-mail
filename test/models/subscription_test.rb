require 'test_helper'

describe Subscription do
  describe "validate delivery_method" do
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
    context "without user" do
      it "should return []" do
        sub = Subscription.new(campaign: campaigns(:one))
        assert_equal [], sub.enabled_delivery_methods
      end
    end

    context "user with free plan" do
      context "with FCM token" do
        it "should return [:webpush]" do
          user = users(:free_with_fcm)
          sub = user.subscriptions.new(campaign: campaigns(:one))
          assert_equal [:webpush], sub.enabled_delivery_methods
        end
      end

      context "without FCM token" do
        it "should return []" do
          user = users(:free)
          sub = user.subscriptions.new(campaign: campaigns(:one))
          assert_equal [], sub.enabled_delivery_methods
        end
      end
    end

    context "user with basic plan" do
      context "with FCM token" do
        it "should return [:email, :webpush]" do
          user = users(:basic_with_fcm)
          sub = user.subscriptions.new(campaign: campaigns(:one))
          assert_equal [:email, :webpush], sub.enabled_delivery_methods
        end
      end

      context "without FCM token" do
        it "should return [:email]" do
          user = users(:basic)
          sub = user.subscriptions.new(campaign: campaigns(:one))
          assert_equal [:email], sub.enabled_delivery_methods
        end
      end
    end
  end

  describe "subscription_period_should_not_overlap" do
    context "user with free plan" do
      context "when creating a new campaign" do
        it "should be valid if delivery_period is not overlapped" do; end
        it "should be invalid if delivery_period is overlapped" do; end
      end

      context "when subscribing other's campaign" do
        it "should be valid if delivery_period is not overlapped" do; end
        it "should be invalid if delivery_period is overlapped" do; end
      end
    end

    context "user with basic plan" do
      context "when creating a new campaign" do
        it "should be valid if delivery_period is not overlapped" do; end
        it "should be valid even if delivery_period is overlapped" do; end
      end

      context "when subscribing other's campaign" do
        it "should be valid if delivery_period is not overlapped" do; end
        it "should be valid even if delivery_period is overlapped" do; end
      end
    end
  end

  describe "destroy" do
    context "when campaign has no more subscriptions" do
      it "should destroy campaign" do
        campaign = campaigns(:two)
        subscription = campaign.subscriptions.create!(user: users(:basic), delivery_method: :email)

        assert_difference('Campaign.count', -1) do
          subscription.destroy
        end
      end
    end

    context "when campaign has other subscriptions" do
      it "should leave campaign alive" do
        subscription = subscriptions(:webpush)

        assert_no_difference('Campaign.count') do
          subscription.destroy
        end
      end
    end
  end
end
