# frozen_string_literal: true

set :application, 'feuerwehrsport-statistik'
set :repo_url, 'git@github.com:Feuerwehrsport/feuerwehrsport-statistik-website.git'
set :deploy_to, '/srv/feuerwehrsport-statistik'

set :rvm_ruby_version, '3.3.7'

set :systemd_usage, true
