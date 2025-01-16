class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :campaign

  enum :delivery_method, { webpush: "webpush", email: "email" }, prefix: :deliver_by

  DELIVERY_METHOD_REQUIREMENTS = {
    email: -> (user) { user.basic_plan? },
    webpush: -> (user) { user.fcm_device_token.present? }
  }.freeze

  after_create :subscribe_to_webpush_topic, if: -> (sub) { sub.deliver_by_webpush? }
  after_destroy :unsubscribe_from_webpush_topic, if: -> (sub) { sub.deliver_by_webpush? }

  validates :delivery_method, inclusion: { in: ->(sub) { sub.user.enabled_delivery_methods.map(&:to_s) } }


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
