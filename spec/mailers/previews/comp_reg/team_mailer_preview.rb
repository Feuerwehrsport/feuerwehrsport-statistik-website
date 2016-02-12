# Preview all emails at http://localhost:3000/rails/mailers/comp_reg/team_mailer
class CompReg::TeamMailerPreview < ActionMailer::Preview
  def notification_to_creator
    CompReg::TeamMailer.notification_to_creator(CompReg::Team.first)
  end
end
