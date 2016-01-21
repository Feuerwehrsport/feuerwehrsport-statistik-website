class Ability
  include CanCan::Ability

  def initialize(user)
    all_users

    send(:"#{user.role}_abilities") if user.try(:role).in?([:admin, :sub_admin, :user, :api_user])
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
  end

  def user_abilities
    api_user_abilities
  end

  def api_user_abilities
    can :create, Appointment
    can :create, ChangeRequest
    can :create, Link
    can :create, Person
    can :update, Place
    can :update, Score
    can [:create, :update], Team
    can :update_person_participation, GroupScore
  end

  def all_users
    can :create, APIUser
    can :read, Appointment
    can :read, Competition
    can :read, Event
    can :read, GroupScoreCategory
    can :read, GroupScoreType
    can :read, GroupScore
    can :read, Nation
    can :read, Person
    can :read, Place
    can :read, Score
    can :read, ScoreType
    can :read, Team
  end
end
