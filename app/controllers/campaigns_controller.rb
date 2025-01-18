class CampaignsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show feed ]
  after_action :verify_authorized, only: %i[ create destroy ]

  def index
  end

  def create
    authorize Campaign
    @campaign = current_user.campaigns.new(campaign_params)

    if @campaign.save
      CreateAndScheduleFeedsJob.perform_later(campaign_id: @campaign.id)
      CampaignMailer.with(user: current_user, campaign: @campaign).scheduled.deliver_later
      flash[:success] = '配信予約が完了しました！予約内容をメールでお送りしていますのでご確認ください。'
      redirect_to campaign_path(@campaign)
    else
      @book = Book.find(@campaign.book_id)
      @meta_title = @book.title

      flash.now[:error] = @campaign.errors.full_messages.join('. ')
      render template: 'books/show', status: 422
    end
  end

  def show
    @campaign = Campaign.find(params[:id])
    @feeds = Feed.delivered_before(Time.current).where(campaign_id: @campaign.id).order(position: :desc).limit(10)
    @subscription = current_user.subscriptions.find_or_initialize_by(campaign_id: @campaign.id) if authenticated?
    @meta_title = @campaign.author_and_book_name
    @breadcrumbs = [ {text: '配信管理', link: subscriptions_path}, {text: @meta_title} ] if @subscription

    # 配信期間が重複している配信が存在してるかチェック
    if authenticated? && current_user.id != @campaign.user_id
      @overlapping_campaigns = current_user.subscribing_campaigns.where.not(id: @campaign.id).overlapping_with(@campaign.end_date, @campaign.start_date)
    end
  end

  def destroy
    @campaign = authorize Campaign.find(params[:id])
    CampaignMailer.with(user: current_user, author_and_book_name: @campaign.author_and_book_name, delivery_period: @campaign.delivery_period).canceled.deliver_later
    @campaign.destroy!

    flash[:success] = '配信を削除しました！'
    redirect_to subscriptions_path, status: 303
  end

  def feed
    @campaign = Campaign.find(params[:id])
    @feeds = @campaign.feeds.delivered_before(Time.current).order('feeds.position DESC').limit(20)
  end

  private

    def campaign_params
      params.require(:campaign).permit(
        :book_id,
        :book_title,
        :author_name,
        :start_date,
        :end_date,
        :delivery_time,
        :delivery_method,
        :color,
        subscriptions_attributes: [
          :user_id,
          :delivery_method,
        ],
      )
    end
end
