class Ability
  include CanCan::Ability
  attr_reader :user

  def initialize(user, _login)
    @user = user
    all_users
    send(:"#{user.role}_abilities") if user.try(:role).in?(%i[admin sub_admin user api_user])
  end

  private

  def admin_abilities
    can :manage, :all
  end

  def sub_admin_abilities
    user_abilities

    can :manage, Appointment
    can :manage, ChangeRequest
    can :manage, Competition
    can :manage, CompetitionFile
    can :manage, Event
    can :manage, GroupScoreCategory
    can :manage, GroupScoreType
    can :manage, GroupScore
    can :manage, Link
    can :manage, Person
    can :manage, Place
    can :manage, ScoreType
    can :manage, Score
    can :manage, Team
    can :manage, Import::Scores
    can :manage, Link
    can :manage, Nation
    can :manage, Repairs::TeamScoreMove
    can :manage, PersonSpelling
    can :manage, PersonParticipation

    can :manage, ImportRequest
  end

  def user_abilities
    api_user_abilities

    can :manage, Registrations::Competition, admin_user_id: user.id
    can :participate, Registrations::Competition, Registrations::Competition.open do |competition|
      competition.date >= Date.today &&
        (competition.open_at.nil? || competition.open_at <= Time.now) &&
        (competition.close_at.nil? || competition.close_at >= Time.now)
    end
    can :manage, Registrations::Team, Registrations::Team.manageable_by(user) do |team|
      can?(:participate, team.competition) &&
        (team.admin_user_id == user.id || team.competition.admin_user_id == user.id)
    end
    can :manage, Registrations::Person, Registrations::Person.manageable_by(user) do |person|
      can?(:participate, person.competition) &&
        (person.admin_user_id == user.id || person.competition.admin_user_id == user.id)
    end

    can %i[index show], ImportRequest, admin_user_id: user.id
    can :create, ImportRequest

    can %i[logout show update], AdminUser, id: user.id
  end

  def api_user_abilities
    can :create, Appointment
    can :update, Appointment, creator: @user
    can :create, ChangeRequest
    can :create, CompetitionFile
    can %i[create show], Link
    can :create, Person
    can :update, Place
    can :update, Score
    can %i[create update], Team
    can :person_participation, GroupScore
  end

  def all_users
    can %i[create status logout], APIUser
    can :read, Appointment
    can :read, Competition
    can :read, ChangeLog
    can :read, Event
    can :read, GroupScoreCategory
    can :read, GroupScoreType
    can :read, GroupScore
    can :read, Nation
    can :read, NewsArticle
    can :read, Person
    can :read, PersonSpelling
    can :read, Place
    can :read, Score
    can :read, ScoreType
    can :read, Team
    can :read, TeamMember
    can :read, TeamSpelling
    can %i[read best_performance best_scores], Year

    can :read, Series::Assessment
    can :read, Series::Cup
    can :read, Series::Participation
    can :read, Series::Round

    can :read, Registrations::Competition, published: true

    can(:manage, M3::Login::Session)
    can(:manage, M3::Login::PasswordReset)
    can(:manage, M3::Login::ChangedEmailAddress)
    can(:create, AdminUsers::Registration)
  end
end
