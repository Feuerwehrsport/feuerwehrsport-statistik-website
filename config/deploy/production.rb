# -*- coding: utf-8 -*-

set :rails_env, "production"


set :rails_cache, "public/cache"

server "www.feuerwehrsport-statistik.de", :app, :web, :db, primary: true
ssh_options[:port] = 2412

set :nginx_use_ssl, false
set :nginx_server_name, "www.feuerwehrsport-statistik.de"
set :unicorn_workers, 2

set :branch, "master"
