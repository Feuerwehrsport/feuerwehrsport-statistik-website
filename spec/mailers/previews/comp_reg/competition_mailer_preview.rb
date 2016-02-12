# Preview all emails at http://localhost:3000/rails/mailers/comp_reg/competition_mailer
class CompReg::CompetitionMailerPreview < ActionMailer::Preview
  def new_team_registered
    CompReg::CompetitionMailer.new_team_registered(CompReg::Team.first)
  end

  def new_person_registered
    CompReg::CompetitionMailer.new_person_registered(CompReg::Person.first)
  end
end
