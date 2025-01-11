class CampaignMailer < ApplicationMailer
  def canceled
    @user = params[:user]
    @author_title = params[:author_title]
    @delivery_period = params[:delivery_period]

    xsmtp_api_params = { category: 'schedule_canceled' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)
    mail(to: @user.email_address, subject: "【ブンゴウメール】配信予約をキャンセルしました")
  end

  def scheduled
    @user = params[:user]
    @campaign = params[:campaign]

    xsmtp_api_params = { category: 'schedule_completed' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)
    mail(to: @user.email_address, subject: "【ブンゴウメール】配信予約が完了しました")
  end
end
