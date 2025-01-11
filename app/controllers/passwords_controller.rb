class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]

  def new
    @meta_title = "パスワード再設定"
  end

  def create
    if user = User.find_by(email_address: params[:email_address])
      PasswordMailer.reset(user).deliver_now
    end

    flash[:info] = "パスワード再設定メールをお送りしました。メール内のURLからパスワードを再設定してください。"
    redirect_to new_session_path
  end

  def edit
    @meta_title = "パスワード再設定"
  end

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      flash[:success] = "パスワードを更新しました！"
      redirect_to new_session_path
    else
      flash[:error] = "パスワードが一致しません。もう一度ご確認ください。"
      redirect_to edit_password_path(params[:token])
    end
  end

  private

    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
    end
end
