class Feed < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :campaign

  # 配信日が昨日以前のもの or 配信日が今日ですでに配信時刻を過ぎているもの
  scope :delivered, -> {
    Feed.joins(:campaign).where("campaigns.start_date + (feeds.position - 1) * interval '1 day' < ?", Time.zone.today)
      .or(
        Feed.joins(:campaign)
          .where("campaigns.start_date + (feeds.position - 1) * interval '1 day' = ?", Time.zone.today)
          .where("campaigns.delivery_time < ?", Time.current.strftime("%T"))
      )
  }

  def deliver
    BungoMailer.with(feed: self).feed_email.deliver_now
    Webpush.notify(webpush_payload)
  end

  def delivery_date
    campaign.start_date + ( position - 1 ).days
  end

  def send_at
    Time.zone.parse("#{delivery_date.to_s} #{campaign.delivery_time}")
  end

  private

    def webpush_payload
      {
        message: {
          name: id,
          topic: campaign_id,
          notification: {
            title: campaign.author_and_book_name,
            body: content.truncate(100),
            image: "/favicon.ico",
          },
          webpush: {
            fcm_options: {
              link: feed_url(id),
            }
          },
        }
      }
    end
end
