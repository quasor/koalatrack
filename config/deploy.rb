set :application, "koalatrack"
set :scm, :git
set :repository,  "git@github.com:quasor/koalatrack.git"
set :branch, "master"
set :deploy_via, :remote_cache
set :user, 'andrew'
set :ssh_options, { :forward_agent => true }


# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:

set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

set :use_sudo, false

role :app, '172.30.145.57'
role :web, '172.30.145.57'
role :db,  '172.30.145.57', :primary => true

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
    restart_sphinx
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end


end

task :after_update_code, :roles => :app do
   run "ln -nfs '#{shared_path}/file_attachments' '#{release_path}/public/file_attachments'"
   run "ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx"
end


desc "Stop the sphinx server"
task :stop_sphinx , :roles => :app do
  run "cd #{current_path} && rake thinking_sphinx:stop RAILS_ENV=production"
end

desc "Start the sphinx server" 
task :start_sphinx, :roles => :app do
  run "cd #{current_path} && rake thinking_sphinx:configure RAILS_ENV=production && rake thinking_sphinx:start RAILS_ENV=production"
end

desc "index the sphinx server" 
task :i_sphinx, :roles => :app do
  run "cd #{current_path} && rake thinking_sphinx:index RAILS_ENV=production"
end

desc "Restart the sphinx server"
task :restart_sphinx, :roles => :app do
	i_sphinx
end
