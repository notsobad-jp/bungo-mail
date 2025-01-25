require 'test_helper'

describe Campaign do
  describe "finished" do
    it "should return finished campaigns" do
      finished_campaign = campaigns(:one)
      unfinished_campaign = campaigns(:three)
      finished_campaigns = Campaign.finished(by: "2025-03-01 00:00")

      assert finished_campaigns.include?(finished_campaign)
      assert finished_campaigns.exclude?(unfinished_campaign)
    end

    it "should not return unfinished campaigns" do
      finished_campaign = campaigns(:one)
      unfinished_campaign = campaigns(:three)
      unfinished_campaigns = Campaign.unfinished(by: "2025-03-01 00:00")

      assert unfinished_campaigns.exclude?(finished_campaign)
      assert unfinished_campaigns.include?(unfinished_campaign)
    end
  end

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

    it "should return created campaign without subscription" do
      user = users(:free)

      campaigns = Campaign.created_or_subscribed_by(user)
      assert_includes campaigns, campaigns(:three)
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

    it "should return only one campaign when created and subscribed by the same user" do
      user = users(:free)

      campaigns = Campaign.created_or_subscribed_by(user)
      assert_equal campaigns.uniq.count, campaigns.count
    end
  end
end
