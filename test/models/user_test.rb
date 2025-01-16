require 'test_helper'

describe User do
  describe "enabled_delivery_methods" do
    context "user with free plan" do
      context "with FCM token" do
        it "should return [:webpush]" do
          user = users(:free_with_fcm)
          assert_equal [:webpush], user.enabled_delivery_methods
        end
      end

      context "without FCM token" do
        it "should return []" do
          user = users(:free)
          assert_equal [], user.enabled_delivery_methods
        end
      end
    end

    context "user with basic plan" do
      context "with FCM token" do
        it "should return [:email, :webpush]" do
          user = users(:basic_with_fcm)
          assert_equal [:email, :webpush], user.enabled_delivery_methods
        end
      end

      context "without FCM token" do
        it "should return [:email]" do
          user = users(:basic)
          assert_equal [:email], user.enabled_delivery_methods
        end
      end
    end
  end
end
