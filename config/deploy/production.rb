set :rails_env, 'production'

server 'stadthafen-rails', :app, :web, :db, primary: true
ssh_options[:port] = 1322

set :nginx_server_name, 'www.feuerwehrsport-statistik.de'
set :unicorn_workers, 2
# set :nginx_default_server, true
set :nginx_other_server_names, 'feuerwehrsport-statistik.de'
# set :nginx_other_server_names, "_" # for all names

set :branch, 'master'

set :nginx_use_ssl, true
set :nginx_upload_local_certificate, false
# set :unicorn_workers, 2

# set :http_proxy, 'http://proxy.server.de:8080'

# set :default_environment, fetch(:default_environment).merge({
#   'http_proxy' => fetch(:http_proxy),
#   'https_proxy' => fetch(:http_proxy),
# })
