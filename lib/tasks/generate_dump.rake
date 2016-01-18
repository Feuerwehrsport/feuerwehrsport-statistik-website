desc ""
task :generate_dump, [] => :environment do |task, args|

unless Rails.env.test_dump?
  raise "only RAILS_ENV=test_dump allowed"
end

sql_file = File.join(Rails.root, "spec", "fixtures", "db", "dump.sql.gz")
config   = Rails.configuration.database_configuration
development = config["development"]
test_dump = config["test_dump"]

client = PG.connect( dbname: development["database"], user: development["username"], password: development["password"], host: development["host"])

[:table, :view].each do |type|
  drop_tables_sql = "select 'drop #{type} if exists \"' || #{type}name || '\" cascade;'  from pg_#{type}s where schemaname = 'public';"
  ActiveRecord::Base.connection.execute(drop_tables_sql).values.each do |sql|
    ActiveRecord::Base.connection.execute(sql.first)
  end
end
Rake::Task["db:migrate"].invoke
[
  Event,
  Place,
  ScoreType,
  Team,
  Competition,
  GroupScoreType,
  GroupScoreCategory,
  GroupScore,
  Nation,
  Person,
  Score,
  PersonParticipation,
  PersonSpelling,
  AdminUser,
  News,
  Appointment,
  Link,
  CompetitionFile,
  TeamSpelling,
].each(&:reset_column_information)


puts "events"
event_ids = []
client.query("SELECT * FROM events WHERE id < 100 ORDER BY id").each do |row|
  event_ids.push(row["id"])
  Event.create!(
    id: row["id"],
    name: row["name"],
    created_at: row["created_at"],
    updated_at: row["updated_at"],
  )
end

puts "places"
place_ids = []
client.query("SELECT * FROM places WHERE id < 100 ORDER BY id").each do |row|
  place_ids.push(row["id"])
  Place.create!(
    id: row["id"],
    name: row["name"],
    latitude: row["latitude"],
    longitude: row["longitude"],
    created_at: row["created_at"],
    updated_at: row["updated_at"],
  )
end
Place.find(1).update!(latitude: nil, longitude: nil)

puts "score_types"
score_type_ids = []
client.query("SELECT * FROM score_types WHERE id < 100 ORDER BY id").each do |row|
  score_type_ids.push(row["id"])
  ScoreType.create!(
    id: row["id"],
    people: row["people"],
    run: row["run"],
    score: row["score"],
    created_at: row["created_at"],
    updated_at: row["updated_at"],
  )
end

puts "teams"
team_ids = []
client.query("SELECT * FROM teams WHERE id < 100 ORDER BY id").each do |row|
  team_ids.push(row["id"])
  team = Team.new(
    id: row["id"],
    name: row["name"],
    shortcut: row["shortcut"],
    latitude: row["latitude"],
    longitude: row["longitude"],
    image: row["image"],
    state: row["state"],
    status: row["status"].to_i,
    created_at: row["created_at"],
    updated_at: row["updated_at"],
  )
  team.save!(validate: false)
end

puts "competitions"
competition_ids = []
client.query("SELECT * FROM competitions WHERE id < 500 AND place_id IN (#{place_ids.join(",")}) AND event_id IN (#{event_ids.join(",")}) ORDER BY id").each do |row|
  competition_ids.push(row["id"])
  Competition.create!(
    id: row["id"],
    name: row["name"],
    place_id: row["place_id"],
    event_id: row["event_id"],
    score_type_id: row["score_type_id"],
    date: row["date"],
    published_at: row["published_at"],
    created_at: row["created_at"],
    updated_at: row["updated_at"],
    hint_content: row["hint_content"],
  )
end

puts "group_score_types"
client.query("SELECT * FROM group_score_types ORDER BY id").each do |row|
  GroupScoreType.create!(
    id: row["id"],
    name: row["name"],
    discipline: row["discipline"],
    regular: row["regular"],
    created_at: row["created_at"],
    updated_at: row["updated_at"],
  )
end

puts "group_score_categories"
group_score_category_ids = []
client.query("SELECT * FROM group_score_categories WHERE id < 100 AND competition_id IN (#{competition_ids.join(",")}) ORDER BY id").each do |row|
  group_score_category_ids.push(row["id"])
  GroupScoreCategory.create!(
    id: row["id"],
    name: row["name"],
    group_score_type_id: row["group_score_type_id"],
    competition_id: row["competition_id"],
    created_at: row["created_at"],
    updated_at: row["updated_at"],
  )
end

puts "group_scores"
group_score_ids = []
client.query("SELECT * FROM group_scores WHERE team_id IN (#{team_ids.join(",")}) AND group_score_category_id IN (#{group_score_category_ids.join(",")}) AND id < 5000 ORDER BY id").each do |row|
  group_score_ids.push(row["id"])
  GroupScore.create!(
    id: row["id"],
    team_id: row["team_id"],
    team_number: row["team_number"],
    time: row["time"],
    group_score_category_id: row["group_score_category_id"],
    gender: row["gender"].to_i,
    run: row["run"],
    created_at: row["created_at"],
    updated_at: row["updated_at"],
  )
end

puts "nations"
client.query("SELECT * FROM nations ORDER BY id").each do |row|
  Nation.create!(
    id: row["id"],
    name: row["name"],
    iso: row["iso"],
    created_at: row["created_at"],
    updated_at: row["updated_at"],
  )
end

puts "people"
person_ids = []
client.query("SELECT * FROM people WHERE id < 100 ORDER BY id").each do |row|
  person_ids.push(row["id"])
  Person.create!(
    id: row["id"],
    last_name: row["last_name"],
    first_name: row["first_name"],
    gender: row["gender"].to_i,
    nation_id: row["nation_id"],
    created_at: row["created_at"],
    updated_at: row["updated_at"],
  )
end

puts "scores"
client.query("SELECT * FROM scores WHERE (team_id IN (#{team_ids.join(",")}) OR team_id IS NULL) AND person_id IN (#{person_ids.join(",")}) AND competition_id IN (#{competition_ids.join(",")}) AND id < 5000 ORDER BY id").each do |row|
  Score.create!(
    id: row["id"],
    person_id: row["person_id"],
    discipline: row["discipline"],
    competition_id: row["competition_id"],
    time: row["time"],
    team_id: row["team_id"],
    team_number: row["team_number"],
    created_at: row["created_at"],
    updated_at: row["updated_at"],
  )
end

puts "person_participations"
client.query("SELECT * FROM person_participations WHERE person_id IN (#{person_ids.join(",")}) AND group_score_id IN (#{group_score_ids.join(",")}) ORDER BY id").each do |row|
  PersonParticipation.create!(
    id: row["id"],
    person_id: row["person_id"],
    group_score_id: row["group_score_id"],
    position: row["position"],
    created_at: row["created_at"],
    updated_at: row["updated_at"],
  )
end

puts "admin_users"
AdminUser.create!(
  name: "Test-Admin",
  role: "admin",
  email: "a@a.de",
  password: "asdf1234",
  confirmed_at: DateTime.parse("2015-01-01 14:11"),
)

puts "news"
client.query("SELECT * FROM news WHERE id < 15 ORDER BY id").each do |row|
  News.create!(
    id: row["id"],
    title: row["title"],
    content: row["content"],
    published_at: row["published_at"],
    admin_user: AdminUser.first,
    created_at: row["created_at"],
    updated_at: row["updated_at"],
  )
end

puts "appointments"
client.query("SELECT * FROM appointments WHERE id < 30 AND (place_id IN (#{place_ids.join(",")}) OR place_id IS NULL) AND (event_id IN (#{event_ids.join(",")}) OR event_id IS NULL) ORDER BY id").each do |row|
  Appointment.create!(
    id: row["id"],
    dated_at: row["dated_at"],
    name: row["name"],
    description: row["description"],
    place_id: row["place_id"],
    event_id: row["event_id"],
    disciplines: row["disciplines"],
    published_at: row["published_at"],
    created_at: row["created_at"],
    updated_at: row["updated_at"],
  )
end

puts "links"
client.query("SELECT * FROM links ORDER BY id").each do |row|
  link = Link.new(
    id: row["id"],
    label: row["label"],
    url: row["url"],
    linkable_id: row["linkable_id"],
    linkable_type: row["linkable_type"],
    created_at: row["created_at"],
    updated_at: row["updated_at"],
  )
  link.save!(validate: false)
end

puts "competition_files"
client.query("SELECT * FROM competition_files WHERE competition_id IN (#{competition_ids.join(",")}) ORDER BY id").each do |row|
  competition_file = CompetitionFile.new(
    file: row["file"],
    keys_string: row["keys_string"],
    competition_id: row["competition_id"],
    created_at: row["created_at"],
    updated_at: row["updated_at"],
  )
  competition_file.save!(validate: false)
end

puts "team_spellings"
client.query("SELECT * FROM team_spellings WHERE team_id IN (#{team_ids.join(",")}) ORDER BY id").each do |row|
  TeamSpelling.create!(
    team_id: row["team_id"],
    name: row["name"],
    shortcut: row["shortcut"],
    created_at: row["created_at"],
    updated_at: row["updated_at"],
  )
end

puts "person_spellings"
client.query("SELECT * FROM person_spellings WHERE person_id IN (#{person_ids.join(",")}) ORDER BY id").each do |row|
  PersonSpelling.create!(
    person_id: row["person_id"],
    first_name: row["first_name"],
    last_name: row["last_name"],
    gender: row["gender"].to_i,
    official: row["official"].to_i,
    created_at: row["created_at"],
    updated_at: row["updated_at"],
  )
end

ActiveRecord::Base.connection.tables.each do |table|
  begin
    result = ActiveRecord::Base.connection.execute("SELECT id FROM #{table} ORDER BY id DESC LIMIT 1")
  rescue
    puts "Warning: not procesing table #{table}. Id is missing?"
    next
  end
  ai_val = result.any? ? result.first['id'].to_i + 1 : 1
  puts "Resetting auto increment ID for #{table} to #{ai_val}"
  ActiveRecord::Base.connection.execute("ALTER SEQUENCE #{table}_id_seq RESTART WITH #{ai_val}")
end

Caching::Cleaner.new.perform
Import::AutoSeries.new.perform
Caching::Cleaner.new.perform

`pg_dump -a -U #{test_dump["username"]} -h #{test_dump["host"]} #{test_dump["database"]} -T schema_migrations | gzip > #{sql_file}`

end