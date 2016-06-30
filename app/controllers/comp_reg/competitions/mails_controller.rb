class CompReg::Competitions::MailsController < CompReg::CompRegController
  include CRUD::NewAction
  include CRUD::CreateAction

  protected

  def resource_class
    CompReg::Competitions::Mail
  end

  def build_instance
    resource_class.new(admin_user: current_admin_user, competition: competition)
  end

  def competition
    CompReg::Competition.find(params[:competition_id])
  end

  def permitted_attributes
    super.permit(:subject, :text, :add_registration_file)
  end

  def before_create_success
    flash[:success] = 'E-Mail wird im Hintergrund versendet'

    resource_instance.object.competition.teams.each do |team|
      deliver(CompReg::CompetitionMailer, :team_news, resource_instance, team)
    end

    resource_instance.object.competition.people.where(team_id: nil).each do |person|
      deliver(CompReg::CompetitionMailer, :person_news, resource_instance, person)
    end

    redirect_to competition
  end
end