load 'deploy'
load 'deploy/assets'
load 'config/deploy'

require "rvm/capistrano"
require 'bundler/capistrano'
require "capistrano-nginx-unicorn"
#require "delayed/recipes" # for delayed_job

set :whenever_command, "bundle exec whenever"
set :whenever_environment, defer { stage }
require "whenever/capistrano" # for whenever

namespace :deploy do
  task :remove_generated_stylesheets do
    run_without_rvm "rm -rf #{release_path}/public/generated/stylesheets/*"
  end

  task :full_restart_of_unicorn do
    if stage == :staging
      run "/etc/init.d/unicorn_#{application} stop"
    end
  end

  task :create_relative_url_symlink do
    unless relative_url_root.nil? or relative_url_root.empty?
      run_without_rvm "#{sudo} ln -s . #{latest_release}/public/#{relative_url_root}"
    end
  end

  task :create_symlink_for_generated_files do
    run_without_rvm "rm -rf #{release_path}/public/generated"
    run_without_rvm "mkdir -p #{shared_path}/generated"
    run_without_rvm "ln -nfs #{shared_path}/generated #{release_path}/public/generated"
  end

  task :create_symlink_for_uploaded_files do
    run_without_rvm "rm -rf #{release_path}/public/uploads"
    run_without_rvm "mkdir -p #{shared_path}/uploads"
    run_without_rvm "ln -nfs #{shared_path}/uploads #{release_path}/public/uploads"
  end
end

namespace :rvm do
  task :install_pgp_keys do
    key = "409B6B1796C275462A1703113804BB82D39DC0E3"
    run_without_rvm "gpg --list-keys #{key} || gpg --keyserver hkp://keys.gnupg.net --recv-keys #{key}"
  end
end

namespace :unicorn do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn (init.d)"
    task command, roles: :app do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end
end

def compile_template_and_upload(template_name, upload_file_path)
  config_file = "#{fetch(:templates_path)}/#{template_name}"
  content = StringIO.new(ERB.new(File.read(config_file)).result(binding))
  put content.read, upload_file_path
end

def compile_template_to_executeable(template_name, upload_file_path)
  compile_template_and_upload(template_name, "/tmp/#{template_name}.tmp")
  run_without_rvm "#{sudo} mv /tmp/#{template_name}.tmp #{upload_file_path}"
  run_without_rvm "#{sudo} chmod +x #{upload_file_path}" 
  run_without_rvm "#{sudo} chown root:root #{upload_file_path}" 
end

namespace :deploy_setup do
  task :nginx_logrotate do
    config_name = "#{fetch :application}_nginx"
    compile_template_and_upload("logrotate_nginx.erb", "/tmp/#{config_name}")
    run_without_rvm "#{sudo} mv /tmp/#{config_name} /etc/logrotate.d/#{config_name}"
    run_without_rvm "#{sudo} chown root:root /etc/logrotate.d/#{config_name}"
    run_without_rvm "#{sudo} mkdir -p #{shared_path}/log/nginx"
    run_without_rvm "#{sudo} chown www-data:www-data #{shared_path}/log/nginx"
  end

  task :setup_shortcuts do
    shortcut_basename = "/usr/bin/#{fetch :application}."
    console_basename = "#{shortcut_basename}console"
    rake_basename = "#{shortcut_basename}rake"
    delayed_job_basename = "#{shortcut_basename}delayed_job"

    compile_template_to_executeable("start_console.erb", console_basename)
    compile_template_to_executeable("start_rake.erb", rake_basename)
    compile_template_to_executeable("start_delayed_job.erb", delayed_job_basename)

    compile_template_and_upload("irbrc.erb", "/home/#{fetch :user}/.irbrc")
  end

  task :fix_setup_permissions do
    run_without_rvm "#{sudo} chown -R #{user} #{shared_path}/.."
  end

  task :create_deploy_to do
    run_without_rvm "#{sudo} mkdir -p #{deploy_to}"
    run_without_rvm "#{sudo} chown #{user}:#{user} #{deploy_to}"
    run_without_rvm "touch /home/#{fetch :user}/#{fetch :application}_env_vars"
  end

  task :install_packages do
    desc "Install required system packages"

    run_without_rvm "#{sudo} apt-get -q -y update"
    run_without_rvm "#{sudo} apt-get -q -y install #{required_packages}"
  end

  task :install_certs do
    desc "Install nginx certificates"

    if nginx_use_ssl
      key_path = "/etc/ssl/private/#{nginx_ssl_certificate_key}"
      cert_path = "/etc/ssl/certs/#{nginx_ssl_certificate}"

      install_nginx_certs  = "  openssl genrsa -out #{key_path} 4096 "
      install_nginx_certs += "; openssl req -new -key #{key_path} -out #{cert_path} -subj '/C=DE/CN=#{nginx_server_name}' "
      install_nginx_certs += "; openssl x509 -req -days 1000 -in #{cert_path} -signkey #{key_path} -out #{cert_path} "

      tests_for_certs = "if [[ ! -f /etc/ssl/private/#{nginx_ssl_certificate_key} ]] ; then #{install_nginx_certs} ; fi"
      run_without_rvm "#{sudo} bash -c \"#{tests_for_certs}\""
    end
  end

  task :create_database do
    database_config = YAML.load_file('config/database.yml')
    username = database_config[stage.to_s]["username"]
    password = database_config[stage.to_s]["password"]
    database = database_config[stage.to_s]["database"]
    desc "Create a database for this application."

    select_sql = "SELECT 1 FROM pg_roles WHERE rolname='#{username}'"
    create_sql = "CREATE USER \"#{username}\" WITH PASSWORD '#{password}';"
    command = "psql postgres -tAc \"#{select_sql}\" | grep -q 1 || psql -c \"#{create_sql.gsub('"', '\\\\\\"')}\""
    run_without_rvm %Q{#{sudo} sudo -u postgres sh -c "#{command.gsub('"', '\\"')}"}

    command = "psql -l | grep -q #{database} || createdb -E UTF-8 -O #{username} #{database}"
    run_without_rvm %Q{#{sudo} sudo -u postgres sh -c "#{command.gsub('"', '\\"')}"}
  end

  task :configure_git_http_proxy do
    unless fetch(:http_proxy).nil?
      run_without_rvm "git config --global http.proxy #{http_proxy}"
    end
  end
end


namespace :rvm do
  task :install_bundler do
    run "gem install bundler"
  end
end