class Feed < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :campaign

  scope :delivered, ->(before: Time.current) {
    joins(:campaign).where(
      "campaigns.start_date + (feeds.position - 1) * interval '1 day' + campaigns.delivery_time < ?",
      before.strftime("%Y-%m-%d %H:%S")
    )
  }

  def deliver
    FeedMailer.with(feed: self).notify.deliver_now
    Webpush.notify(webpush_payload)
  end

  def deliver_at
    Time.zone.parse("#{delivery_date.to_s} #{campaign.delivery_time}")
  end

  def delivery_date
    campaign.start_date + ( position - 1 ).days
  end

  def schedule(skip_before = Time.current)
    return if deliver_at < skip_before

    FeedDeliveryJob.new(feed_id: id).set(
      wait_until: deliver_at,
      queue: campaign_id,
    )
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
