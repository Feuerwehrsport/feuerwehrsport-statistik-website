# config valid for current version and patch releases of Capistrano
lock '~> 3.12.0'

set :application, 'feuerwehrsport-statistik'
set :repo_url, 'git@gitlab.lichtbit.com:feuerwehrsport/feuerwehrsport-statistik.git'
set :deploy_to, '/srv/feuerwehrsport-statistik'

set :rvm_ruby_version, '2.5.5'
