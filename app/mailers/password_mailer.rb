class PasswordMailer < ApplicationMailer
  def reset(user)
    @user = user

    xsmtp_api_params = { category: 'password_reset' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)
    mail(to: @user.email_address, subject: "【ブンゴウメール】パスワード再設定")
  end
end
