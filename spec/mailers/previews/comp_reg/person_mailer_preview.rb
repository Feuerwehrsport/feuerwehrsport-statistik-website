# Preview all emails at http://localhost:3000/rails/mailers/comp_reg/person_mailer
class CompReg::PersonMailerPreview < ActionMailer::Preview
  def notification_to_creator
    CompReg::PersonMailer.notification_to_creator(CompReg::Person.first)
  end
end
