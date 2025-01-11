# Preview all emails at http://localhost:3000/rails/mailers/passwords_mailer
class PasswordMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/passwords_mailer/reset
  def reset
    PasswordMailer.reset(User.take)
  end
end
