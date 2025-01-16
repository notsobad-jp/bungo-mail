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
end
