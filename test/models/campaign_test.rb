require 'test_helper'

describe Campaign do
  describe "overlapping_with" do
    it "should return overlapping campaigns" do
      refute Campaign.overlapping_with("2024-12-30", "2024-12-31").exists?
      assert Campaign.overlapping_with("2024-12-31", "2025-01-01").exists?
      assert Campaign.overlapping_with("2025-01-04", "2025-01-05").exists?
      refute Campaign.overlapping_with("2025-01-05", "2025-01-06").exists?
    end
  end

  describe "created_or_subscribed_by" do
    it "should return created campaign" do
      user = users(:free)

      campaigns = Campaign.created_or_subscribed_by(user)
      assert_includes campaigns, campaigns(:one)
    end

    it "should return subscribed campaign" do
      user = users(:basic)

      campaigns = Campaign.created_or_subscribed_by(user)
      assert_includes campaigns, campaigns(:one)
    end

    it "should not return not created nor subscribed campaign" do
      user = users(:free)

      campaigns = Campaign.created_or_subscribed_by(user)
      refute_includes campaigns, campaigns(:two)
    end
  end
end
