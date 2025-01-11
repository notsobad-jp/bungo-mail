class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :campaigns, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  scope :activated_in_stripe, -> (active_emails) { where(plan: :free).where(email: active_emails) }  # stripeで購読したけどまだDBの支払いステータスに反映されていないuser
  scope :canceled_in_stripe, -> (active_emails) { where(plan: :basic).where.not(email: active_emails) }  # stripeで解約したけどまだDBの支払いステータスに反映されていないuser

  enum :plan, { free_plan: "free", basic_plan: "basic" }

  VALID_PASSWORD_PATTERN = "(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9]).{8,}"
  validates :email_address, presence: true, uniqueness: true
  validates :password, confirmation: true, on: :create
  validates :password, presence: true,
            format: {
              with: /\A#{VALID_PASSWORD_PATTERN}\z/,
              message: "は半角8文字以上で、英大文字・小文字・数字をそれぞれ1文字以上含む必要があります"
            }
  validates :password_confirmation, presence: true, on: :create


  def subscribe(campaign:, delivery_method:)
    subscriptions.create(campaign:, delivery_method:)
  end

  def trialing?
    trial_start_date && trial_start_date <= Date.current && Date.current <= trial_end_date
  end

  def trial_scheduled?
    trial_start_date && Date.current <= trial_start_date
  end

  class << self
    # stripeで支払い中のメールアドレス一覧
    def active_emails_in_stripe
      emails = []
      subscriptions = Stripe::Subscription.list({limit: 100, expand: ['data.customer']})
      subscriptions.auto_paging_each do |sub|
        emails << sub.customer.email
      end
      raise 'Email duplicated!' if emails.length != emails.uniq.length
      emails
    end
  end
end
