# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "freemarket_sample_0609b"
set :repo_url, "git@github.com:Tatumura/freemarket_sample_0609b.git"
set :linked_files, %w{ config/secrets.yml }

set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')

set :rbenv_type, :user
set :rbenv_ruby, '2.5.1'

set :ssh_options, auth_methods: ['publickey'],
                  keys: ['~/.ssh/mura2125.pem']

set :unicorn_pid, -> { "#{shared_path}/tmp/pids/unicorn.pid" }
set :unicorn_config_path, -> { "#{current_path}/config/unicorn.rb" }
set :keep_releases, 5

set :default_env, {
  rbenv_root: "/usr/local/rbenv",
  path: "/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH",
  AWS_ACCESS_KEY_ID: ENV["AWS_ACCESS_KEY_ID"],
  AWS_SECRET_ACCESS_KEY: ENV["AWS_SECRET_ACCESS_KEY"],
  BASIC_AUTH_USER: ENV["BASIC_AUTH_USER"],
  BASIC_AUTH_PASSWORD: ENV["BASIC_AUTH_PASSWORD"],
  RECAPTCHA_SITE_KEY: ENV['RECAPTCHA_SITE_KEY'],
  RECAPTCHA_SECRET_KEY: ENV['RECAPTCHA_SECRET_KEY'],
  PAYJP_PRIVATE_KEY_TEST: ENV['PAYJP_PRIVATE_KEY_TEST']
}

after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :restart do
    invoke 'unicorn:restart'
  end

  desc 'upload secrets.yml'
  task :upload do
    on roles(:app) do |host|
      if test "[ ! -d #{shared_path}/config ]"
        execute "mkdir -p #{shared_path}/config"
      end
      upload!('config/secrets.yml', "#{shared_path}/config/secrets.yml")
    end
  end
  before :starting, 'deploy:upload'
  after :finishing, 'deploy:cleanup'
end
