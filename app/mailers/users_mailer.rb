class UsersMailer < ApplicationMailer
  def registered(user)
    @user = user
    mail subject: "【ブンゴウメール】アカウント登録が完了しました", to: user.email_address
  end
end
