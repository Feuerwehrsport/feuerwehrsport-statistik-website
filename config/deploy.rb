# frozen_string_literal: true

set :application, 'feuerwehrsport-statistik'
set :repo_url, 'git@github.com:Feuerwehrsport/feuerwehrsport-statistik-website.git'
set :deploy_to, '/srv/feuerwehrsport-statistik'

set :rvm_ruby_version, '3.4.8'
set :migration_servers, -> { release_roles(fetch(:migration_role)) }

set :systemd_usage, true

set :enable_solid_queue, true
set :enable_puma, true
