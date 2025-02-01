class Campaign < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :user
  has_many :feeds, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :delayed_jobs, foreign_key: :queue, dependent: :destroy

  accepts_nested_attributes_for :subscriptions

  scope :finished, ->(by: Time.current) {
    where("? > end_at", by)
  }
  scope :unfinished, ->(by: Time.current) {
    where("? <= end_at", by)
  }
  scope :overlapping_with, -> (start_date, end_date) {
    where("end_date >= ? and ? >= start_date", start_date, end_date)
  }

  PATTERNS = ["seigaiha", "asanoha", "sayagata"]

  validates :start_date, presence: true,
    comparison: { less_than_or_equal_to: -> _ { Date.today.since(2.months) } }
  validates :end_date, presence: true,
    comparison: {
      greater_than_or_equal_to: :start_date,
      less_than_or_equal_to: -> campaign { campaign.start_date.since(1.year) }
    }

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

  def og_image_url
    "https://res.cloudinary.com/dm6zgwgiq/image/upload/l_#{color}/e_multiply,fl_layer_apply/fl_relative,fl_no_overflow,co_white,l_text:TakaoExGothic_50_style_align_center:#{ERB::Util.u(author_name)},y_-0.12/fl_relative,fl_no_overflow,co_white,l_text:TakaoExGothic_100_bold_style_align_center:#{ERB::Util.u(book_title)},y_0.05/fl_relative,co_white,l_text:TakaoExGothic_30_style_align_center:#{ERB::Util.u(delivery_period)},y_0.23/#{pattern}.png"
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
    if start_date == end_date
      start_date.strftime("%Y年%-m月%-d日")
    elsif start_date.year == end_date.year
      "#{start_date.strftime("%Y年%-m月%-d日")} 〜 #{end_date.strftime("%-m月%-d日")}"
    else
      "#{start_date.strftime("%Y年%-m月%-d日")} 〜 #{end_date.strftime("%Y年%-m月%-d日")}"
    end
  end

  def finished?(by: Time.current)
    end_at < by
  end

  def pattern
    PATTERNS[book_id % PATTERNS.length]
  end

  def schedule_feeds
    jobs = feeds.map(&:schedule).compact
    ActiveJob.perform_all_later(jobs) # DelayedJobが対応してないので結局loopして個別にenqueueされる
  end

  def started?(by: Time.current)
    start_at < by
  end

  # メール配信対象
  def subscriber_emails
    subscriptions.where(delivery_method: :email).preload(:user).map(&:user).pluck(:email_address)
  end

  def to_ics_event
    event = Icalendar::Event.new
    event.dtstart = Icalendar::Values::Date.new(start_date, tzid: "Asia/Tokyo")
    event.dtend = Icalendar::Values::Date.new(end_date + 1, tzid: "Asia/Tokyo") # 最終日が除外されてしまうので1日ずらす
    event.summary = author_and_book_name
    event.description = campaign_url(id, host: Rails.application.credentials.dig(:hosts, "bungo-mail"))
    event
  end
end
