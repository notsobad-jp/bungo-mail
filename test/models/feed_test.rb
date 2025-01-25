require 'test_helper'

describe Feed do
  describe "delivered" do
    it "should include feeds scheduled before today" do
      feed = feeds(:one_one)
      assert_includes Feed.delivered(before: Time.zone.parse("2025-01-02 00:00")), feed
    end

    it "should include feeds scheduled today but delivery time is passed" do
      feed = feeds(:one_one)
      assert_includes Feed.delivered(before: Time.zone.parse("2025-01-01 08:00")), feed
    end

    it "should not include feeds scheduled today and delivery time is not passed" do
      feed = feeds(:one_one)
      refute_includes Feed.delivered(before: Time.zone.parse("2025-01-01 06:00")), feed
    end

    it "should not include feeds scheduled after today" do
      feed = feeds(:one_one)
      refute_includes Feed.delivered(before: Time.zone.parse("2024-12-31")), feed
    end

    it "should include only its campaigns's feeds" do
      feed1 = feeds(:one_one)
      feed2 = feeds(:two_one)
      feeds = campaigns(:one).feeds.delivered(before: Time.zone.parse("2100-01-01"))
      assert_includes feeds, feed1
      refute_includes feeds, feed2
    end
  end

  describe "delivery_date" do
    it "should return start_date + position - 1" do
      feed = feeds(:one_two)
      assert_equal Date.parse("2025-01-02"), feed.delivery_date
    end
  end

  describe "deliver_at" do
    it "should return delivery_date + delivery_time" do
      feed = feeds(:one_two)
      feed.campaign.delivery_time = "08:00"
      assert_equal Time.zone.parse("2025-01-02 08:00"), feed.deliver_at
    end
  end
end
