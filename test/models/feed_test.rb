require 'test_helper'

describe Feed do
  describe "delivered_before" do
    it "should include feeds scheduled before today" do
      feed = feeds(:one)
      feed.campaign.update(start_date: "2025-01-01")
      assert_includes Feed.delivered_before(Time.zone.parse("2025-01-02 00:00")), feed
    end

    it "should include feeds scheduled today but delivery time is passed" do
      feed = feeds(:one)
      feed.campaign.update(start_date: "2025-01-01", delivery_time: "11:00")
      assert_includes Feed.delivered_before(Time.zone.parse("2025-01-01 12:00")), feed
    end

    it "should not include feeds scheduled today and delivery time is not passed" do
      feed = feeds(:one)
      feed.campaign.update(start_date: "2025-01-01", delivery_time: "12:00")
      refute_includes Feed.delivered_before(Time.zone.parse("2025-01-01 11:00")), feed
    end

    it "should not include feeds scheduled after today" do
      feed = feeds(:one)
      feed.campaign.update(start_date: "2025-01-02")
      refute_includes Feed.delivered_before(Time.zone.parse("2025-01-01")), feed
    end
  end

  describe "delivery_date" do
    it "should return start_date + position - 1" do
      feed = feeds(:two)
      assert_equal Date.parse("2025-01-02"), feed.delivery_date
    end
  end

  describe "deliver_at" do
    it "should return delivery_date + delivery_time" do
      feed = feeds(:two)
      feed.campaign.delivery_time = "08:00"
      assert_equal Time.zone.parse("2025-01-02 08:00"), feed.deliver_at
    end
  end
end
