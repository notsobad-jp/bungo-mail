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
      flash[:success] = '配信予約が完了しました！'
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
    @feeds = @campaign.feeds.delivered.order(position: :desc).limit(10)
    @subscription = @campaign.subscriptions.find_or_initialize_by(user: current_user)

    @meta_title = @campaign.author_and_book_name
    @meta_image = @campaign.og_image_url
    @breadcrumbs = [ {text: '配信管理', link: subscriptions_path}, {text: @meta_title} ] if @subscription.persisted?
  end

  def destroy
    @campaign = authorize Campaign.find(params[:id])
    @campaign.destroy!

    flash[:success] = '配信を削除しました！'
    redirect_to subscriptions_path, status: 303
  end

  def feed
    @campaign = Campaign.find(params[:id])
    @feeds = @campaign.feeds.delivered.order('feeds.position DESC').limit(20)
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
