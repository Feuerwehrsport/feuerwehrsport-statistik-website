desc ""
task :import_online, [] => :environment do |task, args|
client = Mysql2::Client.new(host: "127.0.0.1", username: ENV["MYSQL_USERNAME"], password: ENV["MYSQL_PASSWORD"], port: 3306, database: "projects_feuerwehrsport")

[:table, :view].each do |type|
  drop_tables_sql = "select 'drop #{type} if exists \"' || #{type}name || '\" cascade;'  from pg_#{type}s where schemaname = 'public';"
  ActiveRecord::Base.connection.execute(drop_tables_sql).values.each do |sql|
    ActiveRecord::Base.connection.execute(sql.first)
  end
end
Rake::Task["db:migrate"].invoke

puts "events"
client.query("SELECT * FROM events ORDER BY id").each do |row|
  Event.create!(
    id: row["id"],
    name: row["name"],
  )
end

puts "places"
client.query("SELECT * FROM places ORDER BY id").each do |row|
  Place.create!(
    id: row["id"],
    name: row["name"],
    latitude: row["latitude"],
    longitude: row["longitude"],
  )
end

puts "score_types"
client.query("SELECT * FROM score_types ORDER BY id").each do |row|
  ScoreType.create!(
    id: row["id"],
    people: row["persons"],
    run: row["run"],
    score: row["score"],
  )
end

puts "teams"
client.query("SELECT * FROM teams ORDER BY id").each do |row|
  Team.create!(
    id: row["id"],
    name: row["name"],
    shortcut: row["short"],
    latitude: row["latitude"],
    longitude: row["longitude"],
    image: row["logo"],
    state: row["state"].to_s,
    status: row["type"] == 'Team' ? 0 : 1,
  )
end

puts "competitions"
client.query("SELECT * FROM competitions ORDER BY id").each do |row|
  Competition.create!(
    id: row["id"],
    name: row["name"].to_s,
    place_id: row["place_id"],
    event_id: row["event_id"],
    score_type_id: row["score_type_id"] == 0 ? nil : row["score_type_id"],
    date: row["date"],
    published_at: row["published"],
    created_at: Time.parse(row["created_at"]),
    updated_at: Time.parse(row["created_at"]),
  )
end

puts "group_score_types"
client.query("SELECT * FROM group_score_types ORDER BY id").each do |row|
  GroupScoreType.create!(
    id: row["id"],
    name: row["name"],
    discipline: row["discipline"].downcase,
    regular: row["regular"],
  )
end

puts "group_score_categories"
client.query("SELECT * FROM group_score_categories ORDER BY id").each do |row|
  GroupScoreCategory.create!(
    id: row["id"],
    name: row["name"],
    group_score_type_id: row["group_score_type_id"],
    competition_id: row["competition_id"],
  )
end

puts "group_scores"
client.query("SELECT * FROM group_scores ORDER BY id").each do |row|
  GroupScore.create!(
    id: row["id"],
    team_id: row["team_id"],
    team_number: row["team_number"],
    time: (row["time"] || 99999999),
    group_score_category_id: row["group_score_category_id"],
    gender: row["sex"] == "female" ? 0 : 1,
    run: row["run"].to_s,
  )
end

puts "nations"
client.query("SELECT * FROM nations ORDER BY id").each do |row|
  Nation.create!(
    id: row["id"],
    name: row["name"],
  )
end

puts "persons"
client.query("SELECT * FROM persons ORDER BY id").each do |row|
  Person.create!(
    id: row["id"],
    last_name: row["name"],
    first_name: row["firstname"].to_s,
    gender: row["sex"] == "female" ? 0 : 1,
    nation_id: row["nation_id"] == 0 ? 1 : (row["nation_id"] || 1),
  )
end

puts "scores"
client.query("SELECT * FROM scores ORDER BY id").each do |row|
  Score.create!(
    id: row["id"],
    person_id: row["person_id"],
    discipline: row["discipline"].downcase,
    competition_id: row["competition_id"],
    time: (row["time"] || 99999999),
    team_id: row["team_id"],
    team_number: row["team_number"],
  )
end

puts "person_participations"
client.query("SELECT * FROM person_participations ORDER BY id").each do |row|
  PersonParticipation.create!(
    id: row["id"],
    person_id: row["person_id"],
    group_score_id: row["score_id"],
    position: row["position"],
  )
end

Import::AutoSeries.new.perform
Caching::Cleaner.new

end