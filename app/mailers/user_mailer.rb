class UserMailer < ApplicationMailer
  def registered(user)
    @user = user

    xsmtp_api_params = { category: 'user_registered' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)
    mail(to: @user.email_address, subject: "【ブンゴウメール】アカウント登録が完了しました")
  end
end
