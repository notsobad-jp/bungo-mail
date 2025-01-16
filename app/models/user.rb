class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :campaigns, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :subscribing_campaigns, through: :subscriptions, source: :campaign
  has_many :created_or_subscribing_campaigns, ->(user) {
              where('campaigns.user_id = :user_id OR campaigns.id IN (:subscribed_ids)',
              user_id: user.id,
              subscribed_ids: user.subscriptions.select(:campaign_id))
            },
            class_name: 'Campaign'

  has_many :upcoming_campaigns, -> { Campaign.upcoming }, class_name: "Campaign"
  validates_length_of :upcoming_campaigns, maximum: 1

  enum :plan, { free: "free", basic: "basic" }, suffix: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  VALID_PASSWORD_PATTERN = "(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9]).{8,}"
  validates :email_address, presence: true, uniqueness: true
  validates :password, confirmation: true, on: :create
  validates :password, presence: true,
            format: {
              with: /\A#{VALID_PASSWORD_PATTERN}\z/,
              message: "は半角8文字以上で、英大文字・小文字・数字をそれぞれ1文字以上含む必要があります"
            }
  validates :password_confirmation, presence: true, on: :create


  def disabled_delivery_methods
    Subscription.delivery_methods.keys.map(&:to_sym) - enabled_delivery_methods
  end

  def enabled_delivery_methods
    Subscription::DELIVERY_METHOD_REQUIREMENTS.select { |_, requirement| requirement.call(self) }.keys
  end
end
