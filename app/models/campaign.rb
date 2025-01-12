class Campaign < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :user
  has_many :feeds, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :delayed_jobs, foreign_key: :queue, dependent: :destroy

  scope :upcoming, -> { where("? <= end_date", Date.current) }
  scope :finished, -> { where("? > end_date", Date.current) }
  scope :subscribed_by, -> (user) { joins(:subscriptions).where(subscriptions: { user_id: user.id }) }
  scope :overlapping_with, -> (start_date, end_date) { where("end_date >= ? and ? >= start_date", start_date, end_date) }

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_should_come_after_start_date
  validate :end_date_should_not_be_too_far # 12ヶ月以上先の予約は禁止
  validate :delivery_period_should_not_overlap, if: -> { user.free_plan? } # 無料ユーザーで期間が重複するレコードが存在すればinvalid

  attr_accessor :delivery_method

  enum :color, {
    red: "red", # bg-red-700
    fuchsia: "fuchsia", # bg-fuchsia-700
    sky: "sky", # bg-sky-700
    teal: "teal", # bg-teal-700
    yellow: "yellow", # bg-yellow-700
    slate: "slate", # bg-slate-700
  }, prefix: true

  enum :pattern, {
    seigaiha: "seigaiha",
    asanoha: "asanoha",
    sayagata: "sayagata",
  }, prefix: true


  def author_and_book_name
    "#{author_name}『#{book_title}』"
  end

  def count
    (end_date - start_date).to_i + 1
  end

  def create_and_subscribe_and_schedule_feeds
    ActiveRecord::Base.transaction do
      save!
      user.subscribe(campaign: self, delivery_method:)
    end
    CreateAndScheduleFeedsJob.perform_later(campaign_id: id)
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

  def schedule_feeds
    jobs = feeds.map do |feed|
      next if feed.send_at < Time.current
      FeedDeliveryJob.new(feed_id: feed.id).set(
        wait_until: feed.send_at,
        queue: id,
      )
    end.compact
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

    # 同一チャネルで期間が重複するレコードが存在すればinvalid(Freeプランのみ)
    def delivery_period_should_not_overlap
      overlapping = Campaign.where.not(id: id).where(user_id: user_id).overlapping_with(start_date, end_date)
      errors.add(:base, "他の配信と期間が重複しています") if overlapping.present?
    end

    def start_date_should_not_be_too_far
      errors.add(:base, "配信開始日は現在から2ヶ月以内に設定してください") if start_date > Date.current.since(2.months)
    end

    def end_date_should_come_after_start_date
      errors.add(:base, "配信終了日は開始日より後に設定してください") if end_date < start_date
    end

    def end_date_should_not_be_too_far
      errors.add(:base, "配信終了日は開始日から12ヶ月以内に設定してください") if end_date > start_date.since(12.months)
    end
end
