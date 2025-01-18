class Campaign < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :user
  has_many :feeds, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :delayed_jobs, foreign_key: :queue, dependent: :destroy

  accepts_nested_attributes_for :subscriptions, reject_if: :delivery_method_blank

  scope :finished, -> { where("? > end_date", Date.current) }
  scope :unfinished, -> { where("? <= end_date", Date.current) }
  scope :overlapping_with, -> (start_date, end_date) {
    where("end_date >= ? and ? >= start_date", start_date, end_date)
  }
  scope :created_or_subscribed_by, -> (user) {
    joins(:subscriptions).where(user_id: user.id).or(
      joins(:subscriptions).where(subscriptions: { user_id: user.id })
    )
  }

  PATTERNS = ["seigaiha", "asanoha", "sayagata"]
  MAX_UNFINISHED_CAMPAIGNS = { free: 1, basic: 5 } # 予約可能キャンペーン数

  validates :start_date, presence: true,
    comparison: { less_than_or_equal_to: -> _ { Date.today.since(2.months) } }
  validates :end_date, presence: true,
    comparison: {
      greater_than_or_equal_to: :start_date,
      less_than_or_equal_to: -> campaign { campaign.start_date.since(1.year) }
    }
  validate :validate_unfinished_campaigns_count

  enum :color, {
    red: "red", # bg-red-700
    fuchsia: "fuchsia", # bg-fuchsia-700
    sky: "sky", # bg-sky-700
    teal: "teal", # bg-teal-700
    yellow: "yellow", # bg-yellow-700
    slate: "slate", # bg-slate-700
  }, prefix: true


  def author_and_book_name
    "#{author_name}『#{book_title}』"
  end

  def count
    (end_date - start_date).to_i + 1
  end

  def create_feeds
    book = Book.find(self.book_id)
    contents = book.contents(count: count)

    feeds = contents.map.with_index(1) do |content, index|
      {
        content: content,
        position: index,
        campaign_id: self.id
      }
    end
    Feed.insert_all feeds
  end

  def delivery_period
    "#{start_date} 〜 #{end_date}"
  end

  def pattern
    PATTERNS[book_id % PATTERNS.length]
  end

  def schedule_feeds
    jobs = feeds.map(&:schedule).compact
    ActiveJob.perform_all_later(jobs) # DelayedJobが対応してないので結局loopして個別にenqueueされる
  end

  # メール配信対象
  def subscriber_emails
    subscriptions.where(delivery_method: :email).preload(:user).map(&:user).pluck(:email)
  end

  def status
    if Date.current < start_date
      "配信予定"
    elsif Date.current > end_date
      "配信終了"
    else
      "配信中"
    end
  end

  def status_color
    case status
    when "配信予定"
      "blue"
    when "配信中"
      "orange"
    when "配信終了"
      "gray"
    end
  end

  def to_ics_event
    event = Icalendar::Event.new
    event.dtstart = Icalendar::Values::Date.new(start_date, tzid: "Asia/Tokyo")
    event.dtend = Icalendar::Values::Date.new(end_date, tzid: "Asia/Tokyo")
    event.summary = author_and_book_name
    event.description = campaign_url(id, host: Rails.application.credentials.dig(:hosts, "bungo-mail"))
    event
  end


  private

    def delivery_method_blank(attributes)
      attributes[:delivery_method].blank?
    end

    def validate_unfinished_campaigns_count
      current_count = user.campaigns.unfinished.count
      limit = MAX_UNFINISHED_CAMPAIGNS[user.plan.to_sym]

      if current_count >= limit
        errors.add(:base, "配信数の上限を超えています。現在のプランの予約上限は「#{limit}本」です。予約済みの配信を削除するか、配信が終わるまでお待ちください")
      end
    end
end
