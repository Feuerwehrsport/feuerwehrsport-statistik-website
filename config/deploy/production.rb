# -*- coding: utf-8 -*-

set :rails_env, "production"

server "www.feuerwehrsport-statistik.de", :app, :web, :db, primary: true
ssh_options[:port] = 2412

set :nginx_use_ssl, false
set :unicorn_workers, 2

set :branch, "master"
