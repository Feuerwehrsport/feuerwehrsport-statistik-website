# -*- coding: utf-8 -*-
set :stages, %w(staging production)

set :default_stage, "staging"

require "capistrano/ext/multistage"
#require "delayed/recipes" # for delayed_job


# application name, this will be used in init.d scripts and nginx file names
set :application, "fws-statistik"

# git repo to check out
set :repository,  "git@github.com:Feuerwehrsport/feuerwehrsport-statistik-website.git"

# deploy application to this directory
set :deploy_to, "/srv/#{fetch :application}"

set :default_environment, 'PATH' => 'PATH=$PATH:/usr/sbin'

set :user, "fws-statistik"
set :use_sudo, false

# required system packages
set :required_packages, "git curl rsync postgresql imagemagick libpq-dev nodejs libyaml-dev libmagickwand-dev libgmp3-dev libmysqlclient-dev"

# libgmp3-dev -> json

set :deploy_via, :rsync_with_remote_cache

# for low bandwidth connection uncomment following line
rsync_excludes = %w{ .git* spec rspec test Capfile config/deploy config/deploy.rb }
set :rsync_options, "-azc --delete --delete-excluded --exclude #{rsync_excludes.join(" --exclude ")}"

# normally, you do not need to change anything beyond this line

set :scm, :git
set :ssh_options, { forward_agent: true }

set :relative_url_root, ""
set :asset_env, "#{asset_env} RAILS_RELATIVE_URL_ROOT=''"

#allocate a pty, needed for sudo password prompts
default_run_options[:pty] = true

set :rvm_ruby_string, "2.2.3"
set :rvm_autolibs_flag, "read-only"
set :http_proxy, nil
set :rails_cache, nil
set :bundle_without, %w{development test test_dump}.join(' ')   


before 'deploy:setup', 'deploy_setup:create_deploy_to'
before 'deploy:setup', 'deploy_setup:install_packages'
before 'deploy:setup', 'deploy_setup:install_certs'
before 'deploy:setup', 'rvm:install_pgp_keys'
before 'deploy:setup', 'rvm:install_rvm'   # install RVM
before 'deploy:setup', 'rvm:install_ruby'  # install Ruby and create gemset
before 'deploy:setup', 'rvm:install_bundler'
before 'deploy:setup', 'deploy_setup:configure_git_http_proxy'

after "deploy:setup", "deploy_setup:fix_setup_permissions"
after "deploy:setup", "deploy_setup:create_database"
after "deploy:setup", "deploy_setup:setup_shortcuts"

after "unicorn:setup", "deploy_setup:nginx_logrotate"


# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

# automatically migrate database at deployment time
after "deploy:update_code", "deploy:migrate"

# create a symlink from public/relative_url_root to public so that nginx can read it
# (we need to use root instead of alias in the nginx config because try_file in combination with alias is broken)
# after "deploy:update_code", "deploy:create_relative_url_symlink"

# create a symlink to share public/generated
after "deploy:update_code", "deploy:create_symlink_for_generated_files"
after "deploy:update_code", "deploy:create_symlink_for_uploaded_files"
after "deploy:update_code", "deploy:remove_generated_stylesheets"

before "deploy", "deploy:full_restart_of_unicorn"

set :delayed_job_command, "bin/delayed_job"
after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"

