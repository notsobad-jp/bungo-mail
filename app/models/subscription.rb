class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :campaign

  enum :delivery_method, { email: "email", webpush: "webpush" }, prefix: true

  after_create :subscribe_to_webpush_topic, if: -> (sub) { sub.delivery_method_webpush? }
  after_destroy :unsubscribe_from_webpush_topic, if: -> (sub) { sub.delivery_method_webpush? }

  private

    def subscribe_to_webpush_topic
      Webpush.subscribe_to_topic!(
        token: user.fcm_device_token,
        topic: campaign_id
      ) if user.fcm_device_token.present?
    end

    def unsubscribe_from_webpush_topic
      Webpush.unsubscribe_from_topic!(
        token: user.fcm_device_token,
        topic: campaign_id
      ) if user.fcm_device_token.present?
    end
end
