class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    redirect_to(mypage_path) if authenticated?

    @user = User.new
    @meta_title = 'アカウント登録'
    @no_index = true
  end

  def create
    @user = User.new(user_params)
    @meta_title = 'アカウント登録'

    if @user.save
      start_new_session_for @user
      UserMailer.registered(@user).deliver_later
      redirect_to(mypage_path, flash: { success: 'ユーザー登録が完了しました！' })
    else
      flash.now[:error] = @user.errors.full_messages.join('. ')
      render :new, status: 422
    end
  end

  def show
    @meta_title = 'マイページ'
    @no_index = true
  end

  # 今のところプッシュ通知の更新にしか使ってない
  def update
    current_user.update_attribute!(:fcm_device_token, params[:token])
    head :ok
  end

  def destroy
    begin
      @user = User.find_by(email_address: params[:email_address])
      if @user.blank?
        flash[:error] = '入力されたメールアドレスで登録が確認できませんでした。入力内容をご確認いただき、それでも解決しない場合はお手数ですが運営までお問い合わせください。'
        redirect_to page_path(:unsubscribe) and return
      end

      # 有料ユーザーのときは処理をスキップして手動削除
      if @user.stripe_customer_id # paid_memberで判定すると、トライアル前の人も削除してstripeだけに残っちゃうので広く拾う
        logger.error "[Error] Paid account cancelled: #{@user.stripe_customer_id}"
      else
        @user.destroy
      end
      flash[:success] = '退会処理を完了しました。すべての課金とメール配信を停止します。これまでのご利用ありがとうございました。'
      redirect_to params[:redirect_to] || root_path
    rescue => e
      logger.error "[Error]Unsubscription failed: #{e.message}, #{params[:email_address]}"
      flash[:error] = '処理に失敗しました。。何回か試してもうまくいかない場合、お手数ですが運営までお問い合わせください。'
      redirect_to page_path(:unsubscribe)
    end
  end

  def webpush_test
    Webpush.notify(webpush_payload)
  rescue
    flash[:error] = 'プッシュ通知のテスト送信に失敗しました。ブラウザの通知許可を再度ご設定ください。'
    redirect_to mypage_path
  end

  private

    def user_params
      params.require(:user).permit(
        :email_address,
        :password,
        :password_confirmation,
      )
    end

    def webpush_payload
      {
        message: {
          name: "プッシュ通知テスト",
          token: current_user.fcm_device_token,
          notification: {
            title: "プッシュ通知テスト",
            body: "ブンゴウメールのプッシュ通知テスト配信です。",
            image: "/favicon.ico",
          },
          webpush: {
            fcm_options: {
              link: mypage_url,
            },
          },
        }
      }
    end
end
