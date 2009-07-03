set :application, 'skeves'
set :scm, :git
set :branch, 'master'
set :repository, 'git://github.com/gnarg/skeves.git'
set :deploy_to, '/home/gnarg/rails/skeves'
set :use_sudo, false
role :app, 'sprocket.slackworks.com'

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
  task :stop, :roles => :app do
    # Do nothing.
  end
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :symlink_configs, :roles => :app, :except => {:no_symlink => true} do
    run %[
      cd #{release_path} &&
      ln -nfs #{shared_path}/config/eve_auth.yml #{release_path}/config/eve_auth.yml
    ]
  end
end
