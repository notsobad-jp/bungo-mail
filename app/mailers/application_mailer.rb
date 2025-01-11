class ApplicationMailer < ActionMailer::Base
  prepend_view_path "app/views/mailers"
  default from: 'ブンゴウメール編集部 <bungomail@notsobad.jp>', to: 'bungomail@notsobad.jp'
  layout false
end
