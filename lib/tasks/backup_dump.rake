task :backup_dump do |task, args|
  excluded_tables = [
    "schema_migrations",
    "admin_users",
    "api_users",
    "change_logs",
    "change_requests",
  ].map { |t| " -T #{t} " }
  backup_path = "/srv/fws-statistik/dump"
  backup_path = "/tmp#{backup_path}" unless Rails.env.production?

  `if [ ! -d #{backup_path} ] ; then mkdir -p #{backup_path} ; cd #{backup_path} ; git init ; fi`
  `pg_dump -a -U fws-statistik -h localhost fws-statistik #{excluded_tables.join} > #{backup_path}/dump.sql`

  `cd #{backup_path}; git add dump.sql`
  unless `cd #{backup_path}; git status`.match("nothing to commit")
    `cd #{backup_path}; git commit -am "Backup #{Date.today}" -q`
    `cd #{backup_path}; git push -q` if Rails.env.production?
  end
end