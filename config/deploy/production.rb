set :rails_env, 'production'

server 'stadthafen-rails', :app, :web, :db,
       primary: true,
       ssh_options: { port: 1322 },
       error_500_url: 'https://feuerwehrsport-statistik.de/500'

set :branch, 'master'
