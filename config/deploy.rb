require 'vendor/plugins/acts_as_ferret/lib/ferret_cap_tasks'

namespace :deploy do
  namespace :mongrel do
    [ :stop, :start, :restart ].each do |t|
      desc "#{t.to_s.capitalize} the mongrel appserver"
      task t, :roles => :app do
        #invoke_command checks the use_sudo variable to determine how to run the mongrel_rails command
        invoke_command "mongrel_rails cluster::#{t.to_s} -C #{mongrel_conf}", :via => run_method 
      end
    end
  end

  desc "Custom restart task for mongrel cluster"
  task :restart, :roles => :app, :except => { :no_release => true } do
    deploy.mongrel.restart
    ferret.restart
  end

  desc "Custom start task for mongrel cluster"
  task :start, :roles => :app do
    deploy.mongrel.start
    ferret.start
  end

  desc "Custom stop task for mongrel cluster"
  task :stop, :roles => :app do
    deploy.mongrel.stop
    ferret.stop
  end

  desc "Set up the shared index"
  task :after_setup, :roles => [:app, :web] do
    run "mkdir -p -m 777 #{shared_path}/index"
  end
  
end


set :application, "koalatrack"
set :repository,  "svn+ssh://qm@youreasyhome.com/home/qm/svn/tcm/trunk"
set :deploy_via, :remote_cache

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

set :user, "acoldham"            # defaults to the currently logged in user

role :app, "koala.ectdev.com"
role :web, "koala.ectdev.com"
role :db,  "koala.ectdev.com", :primary => true

set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml" 

task :after_update_code, :roles => :app do
   run "ln -nfs '#{shared_path}/file_attachments' '#{release_path}/public/file_attachments'"
   run "ln -nfs #{shared_path}/index        #{current_release}/index"
end

 #barrett walter allen orr 
