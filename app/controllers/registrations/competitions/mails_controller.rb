class Registrations::Competitions::MailsController < Registrations::BaseController
  protected

  def resource_class
    Registrations::Competitions::Mail
  end

  def build_instance
    resource_class.new(admin_user: current_admin_user, competition: competition)
  end

  def competition
    Registrations::Competition.find(params[:competition_id])
  end

  def permitted_attributes
    super.permit(:subject, :text, :add_registration_file)
  end

  def before_create_success
    flash[:success] = 'E-Mail wird im Hintergrund versendet'

    resource_instance.object.competition.teams.each do |team|
      deliver(Registrations::CompetitionMailer, :team_news, resource_instance, team)
    end

    resource_instance.object.competition.people.where(team_id: nil).each do |person|
      deliver(Registrations::CompetitionMailer, :person_news, resource_instance, person)
    end

    redirect_to competition
  end
end
