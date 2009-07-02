set :application, "koalatrack"
set :scm, :git
set :repository,  "git@github.com:quasor/koalatrack.git"
set :branch, "master"
set :deploy_via, :remote_cache
set :user, 'user'
set :ssh_options, { :forward_agent => true }


# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:

set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

set :use_sudo, false

role :app, 'koalatrack.gotdns.com'
role :web, 'koalatrack.gotdns.com'
role :db,  'koalatrack.gotdns.com', :primary => true

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

task :after_update_code, :roles => :app do
   run "ln -nfs '#{shared_path}/file_attachments' '#{release_path}/public/file_attachments'"
   run "ln -nfs '#{shared_path}/solr_data' '#{release_path}/vendor/plugins/acts_as_solr/solr/solr/data'"
end
