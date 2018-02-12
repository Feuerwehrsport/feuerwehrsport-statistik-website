class Ipo::RegistrationDecorator < AppDecorator
  delegate :to_s, to: :team_name

  localizes_boolean :youth_team, :female_team, :male_team
end
