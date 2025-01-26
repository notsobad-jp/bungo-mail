class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :campaign

  enum :delivery_method, { webpush: "webpush", email: "email" }, prefix: :deliver_by

  DELIVERY_METHOD_REQUIREMENTS = {
    email: -> (user, _campaign) { user&.basic_plan? },
    webpush: -> (user, _campaign) { user&.fcm_device_token.present? }
  }.freeze

  after_create :subscribe_to_webpush_topic, if: -> (sub) { sub.deliver_by_webpush? }
  after_destroy :unsubscribe_from_webpush_topic, if: -> (sub) { sub.deliver_by_webpush? }

  validates :delivery_method,
    inclusion: { in: ->(sub) { sub.enabled_delivery_methods.map(&:to_s) } },
    allow_blank: { if: ->(sub) { sub.campaign.user_id == sub.user_id } }
  validate :subscription_period_should_not_overlap, if: -> { user.free_plan? }


  def disabled_delivery_methods
    Subscription.delivery_methods.keys.map(&:to_sym) - enabled_delivery_methods
  end

  def enabled_delivery_methods
    DELIVERY_METHOD_REQUIREMENTS.select { |_, requirement| requirement.call(user, campaign) }.keys
  end

  private

    def subscribe_to_webpush_topic
      Webpush.subscribe_to_topic(
        token: user.fcm_device_token,
        topic: campaign_id
      ) if user.fcm_device_token.present?
    end

    def unsubscribe_from_webpush_topic
      Webpush.unsubscribe_from_topic(
        token: user.fcm_device_token,
        topic: campaign_id
      ) if user.fcm_device_token.present?
    end

    def subscription_period_should_not_overlap
      overlapping = user.subscribing_campaigns.overlapping_with(campaign.start_date, campaign.end_date).exists?
      errors.add(:base, "購読中の配信と期間が重複しています") if overlapping
    end
end
