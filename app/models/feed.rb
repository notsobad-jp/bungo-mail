class Feed < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :campaign

  scope :delivered_before, ->(datetime) {
    Feed.joins(:campaign).where(
      "campaigns.start_date + (feeds.position - 1) * interval '1 day' + campaigns.delivery_time < ?",
      datetime.strftime("%Y-%m-%d %H:%S")
    )
  }

  def deliver
    FeedMailer.with(feed: self).feed.deliver_now
    Webpush.notify(webpush_payload)
  end

  def deliver_at
    Time.zone.parse("#{delivery_date.to_s} #{campaign.delivery_time}")
  end

  def delivery_date
    campaign.start_date + ( position - 1 ).days
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
              link: feed_url(id, host: Rails.application.credentials.dig(:hosts, "bungo-mail")),
            }
          },
        }
      }
    end
end
