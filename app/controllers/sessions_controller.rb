class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "しばらく経ってから再度お試しください" }

  def new
    redirect_to mypage_path if authenticated?
    @meta_title = 'ログイン'
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      flash[:error] = "ログインに失敗しました。。。メールアドレスとパスワードを再度ご確認ください。"
      redirect_to new_session_path
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
