class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "【ブンゴウメール】パスワード再設定", to: user.email_address
  end
end
