class SubscriptionsController < ApplicationController
  def index
    @meta_title = "配信管理"

    if params[:finished].present?
      @campaigns = Campaign.created_or_subscribed_by(current_user).finished.order(start_date: :asc).page(params[:page])
    else
      @campaigns = Campaign.created_or_subscribed_by(current_user).unfinished.order(start_date: :asc).page(params[:page])
    end
  end

  def create
    @campaign = Campaign.find(params[:campaign_id])
    @subscription = @campaign.subscriptions.new(subscription_params)
    @subscription.user = current_user

    if @subscription.save
      flash[:success] = '配信の購読が完了しました！'
      redirect_to campaign_path(@campaign)
    else
      @feeds = @campaign.feeds.delivered.order(position: :desc).limit(10)
      @meta_title = @campaign.author_and_book_name

      flash.now[:error] = @subscription.errors.full_messages.join('. ')
      render template: "campaigns/show", status: 422
    end
  end

  def destroy
    subscription = authorize Subscription.find(params[:id])
    subscription.destroy!
    redirect_to campaign_path(subscription.campaign), flash: { success: "配信の購読を解除しました。" }, status: 303
  end

  private

    def subscription_params
      params.require(:subscription).permit(:delivery_method)
    end
end
