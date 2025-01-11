class BungoMailer < ApplicationMailer
  def feed_email
    @feed = params[:feed]
    send_to = params[:send_to] || @feed.campaign.subscriber_emails
    return if send_to.blank?

    @word_count = @feed.content.gsub(" ", "").length
    sender_name = envelope_display_name("#{@feed.campaign.author_name}（ブンゴウメール）")

    xsmtp_api_params = { to: send_to, category: 'feed' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)

    mail(from: "#{sender_name} <bungomail@notsobad.jp>", subject: @feed.campaign.book_title)
  end

  def webpush_failed_email
    @user = params[:user]
    xsmtp_api_params = { category: 'webpush_failed' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)
    mail(to: @user.email, subject: "【ブンゴウメール】プッシュ通知の送信に失敗しました")
  end


  private

    # メール送信名をRFCに準拠した形にフォーマット
    ## http://kotaroito.hatenablog.com/entry/2016/09/23/103436
    def envelope_display_name(display_name)
      name = display_name.dup

      # Special characters
      if name && name =~ /[\(\)<>\[\]:;@\\,\."]/
        # escape double-quote and backslash
        name.gsub!(/\\/, '\\')
        name.gsub!(/"/, '\"')

        # enclose
        name = '"' + name + '"'
      end

      name
    end
end
