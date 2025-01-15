require 'test_helper'

describe Feed do
  describe "delivered" do
    it "should include feeds scheduled before today" do
    end

    it "should include feeds scheduled today but delivery time is passed" do
    end

    it "should not include feeds scheduled today and delivery time is not passed" do
    end

    it "should not include feeds scheduled after today" do
    end
  end

  describe "delivery_date" do
    it "should return start_date + position - 1" do
      feed = feeds(:two)
      assert_equal Date.parse("2025-01-02"), feed.delivery_date
    end
  end

  describe "send_at" do
    it "should return delivery_date + delivery_time" do
      feed = feeds(:two)
      feed.campaign.delivery_time = "08:00"
      assert_equal Time.zone.parse("2025-01-02 08:00"), feed.send_at
    end
  end
end
