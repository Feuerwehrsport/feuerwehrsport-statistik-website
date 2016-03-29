# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


competition = CompReg::Competition.create!(name: "test", date: Date.today + 10.days, place: "hier", description: "Beschreibung", admin_user: AdminUser.first)
hb = CompReg::CompetitionAssessment.create!(competition: competition, discipline: "hb", gender: :male)
hl = CompReg::CompetitionAssessment.create!(competition: competition, discipline: "hl", gender: :male)
team = CompReg::Team.create!(competition: competition, name: "Mannschaft", shortcut: "Manns", gender: :male, admin_user: AdminUser.first)
