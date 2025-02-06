# frozen_string_literal: true

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

    can :manage, Caching::Cleaner
    can :manage, ChangeRequest
    can :manage, Competition
    can :manage, CompetitionFile
    can :manage, Event
    can :manage, GroupScore
    can :manage, GroupScoreCategory
    can :manage, GroupScoreType
    can :manage, Import::Scores
    can :manage, ImportRequest
    can :manage, ImportRequestFile
    can :manage, Link
    can :manage, Link
    can :manage, M3::Asset
    can :manage, M3::ImageAsset
    can :manage, Nation
    can :manage, People::Cleaner
    can :manage, Person
    can :manage, PersonParticipation
    can :manage, PersonSpelling
    can :manage, Place
    can :manage, Repairs::TeamScoreMove
    can :manage, Score
    can :manage, ScoreType
    can :manage, Team
    can :manage, TeamSpelling
  end

  def user_abilities
    api_user_abilities

    can :read, ImportRequest, admin_user_id: user.id
    can %i[create index], ImportRequest

    can %i[logout show update], AdminUser, id: user.id
  end

  def api_user_abilities
    can :create, ChangeRequest
    can :create, CompetitionFile
    can %i[create show], Link
    can :create, Person
    can :update, Place
    can :update, Score
    can %i[create update], Team
    can :person_participation, GroupScore
    can :create, ImportRequest
  end

  def all_users
    basic_stuff

    can :read, Series::Assessment
    can :read, Series::Cup
    can :read, Series::Participation
    can :read, Series::Round
    can :read, Series::Kind

    can(:manage, M3::Login::Session)
    can(:verify, M3::Login::Base)
    can(:manage, M3::Login::PasswordReset)
    can(:manage, M3::Login::ChangedEmailAddress)
    can(:create, AdminUsers::Registration)
  end

  def basic_stuff
    can %i[create status logout], ApiUser
    can :read, Bla::Badge
    can :read, Competition
    can :read, ChangeLog
    can :read, Event
    can :read, GroupScoreCategory
    can :read, GroupScoreType
    can :read, GroupScore
    can :read, Nation
    can :read, Person
    can :read, PersonSpelling
    can :read, Place
    can :read, Score
    can :read, ScoreType
    can :read, SingleDiscipline
    can :read, Team
    can :read, TeamMember
    can :read, TeamSpelling
    can %i[read best_performance best_scores], Year
  end
end
