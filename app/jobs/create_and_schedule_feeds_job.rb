class CreateAndScheduleFeedsJob < ActiveJob::Base
  def perform(campaign_id:)
    campaign = Campaign.find(campaign_id)
    campaign.create_feeds
    campaign.schedule_feeds
  end
end
