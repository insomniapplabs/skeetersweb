require "bundler/capistrano"

server "107.170.45.244", :web, :app, :db, primary: true

set :application, "skeetersweb"
set :user, "deployer"
set :deploy_to, "/home/#{user}/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "https://github.com/insomniapplabs/#{application}.git"
set :branch, "master"
set :normalize_asset_timestamps, false

set :default_environment, {
        'PATH' => "/home/deployer/.rvm/gems/ruby-2.0.0-p353/bin:/home/deployer/.rvm/gems/ruby-2.0.0-p353@global/bin:/home/deployer/.rvm/rubies/ruby-2.0.0-p353/bin:/home/deployer/.rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games",
        'RUBY_VERSION' => '1.9.3p392',
        'GEM_HOME' => '/home/deployer/.rvm/gems/ruby-2.0.0-p353',
        'GEM_PATH' => '/home/deployer/.rvm/gems/ruby-2.0.0-p353:/home/deployer/.rvm/gems/ruby-2.0.0-p353@global'
}

set :shared_children, shared_children + %w{public/uploads}

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:symlink_uploads", "deploy:cleanup" #keep only the last 5 releases


namespace :deploy do
	namespace :assets do
    task :precompile, :roles => assets_role, :except => { :no_release => true } do
      run <<-CMD.compact
        cd -- #{latest_release.shellescape} &&
        #{rake} RAILS_ENV=#{rails_env.to_s.shellescape} #{asset_env} assets:precompile
      CMD
    end
  end
  
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end




# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

#role :web, "your web-server here"                          # Your HTTP server, Apache/etc
#role :app, "your app-server here"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end