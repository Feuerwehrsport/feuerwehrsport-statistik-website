set :rails_env, "staging"

server "www.server.de", :app, :web, :db, primary: true
# ssh_options[:port] = 2412

set :nginx_use_ssl, false
set :nginx_server_name, "www.server.de"
set :nginx_forwarded_http_port, 1380
set :nginx_forwarded_https_port, 13443
set :unicorn_workers, 2

set :nginx_http_authentication_user, 'user'
set :nginx_http_authentication_password, 'secret'

# set :nginx_use_ssl, true
# set :nginx_upload_local_certificate, false
# set :unicorn_workers, 2

# set :http_proxy, 'http://proxy.server.de:8080'

# set :default_environment, fetch(:default_environment).merge({ 
#   'http_proxy' => fetch(:http_proxy),
#   'https_proxy' => fetch(:http_proxy),
# })


# Figure out the name of the current local branch
def current_git_branch
  branch = `git symbolic-ref HEAD 2> /dev/null`.strip.gsub(/^refs\/heads\//, '')
  puts "Deploying branch #{branch}"
  branch
end

# Set the deploy branch to the current branch
set :branch, current_git_branch