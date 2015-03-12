rails_env = ENV['RAILS_ENV'] || 'production'

deploy_to = "/data/rt/app"
rails_root = "#{deploy_to}/current"

pid_dir = "#{deploy_to}/shared/tmp/pids"
FileUtils.mkdir_p(pid_dir, mode: 0777) unless File.directory?(pid_dir)

pid_file = "#{pid_dir}/unicorn.pid"
#socket_file= "#{deploy_to}/shared/sockets/unicorn.sock"
log_file = "#{deploy_to}/shared/log/unicorn.log"
err_log_file = "#{deploy_to}/shared/log/unicorn.error.log"

old_pid_file = pid_file + '.oldbin'

worker_processes 2
working_directory rails_root

timeout 300

# Specify path to socket unicorn listens to,
# we will use this in our nginx.conf later

listen "127.0.0.1:4000"

pid pid_file

# Set log file paths
stderr_path err_log_file
stdout_path log_file

# http://tech.tulentsev.com/2012/03/deploying-with-sinatra-capistrano-unicorn/
# NOTE: http://unicorn.bogomips.org/SIGNALS.html
preload_app true

# make sure that Bundler finds the Gemfile
before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = File.join( rails_root, 'Gemfile' )
end

before_fork do |server, worker|
  # при использовании preload_app = true здесь должно быть закрытие всех открытых сокетов

  # uncomment for AR
  # ActiveRecord::Base.connection.disconnect
  # Mongoid reconnects itself
  # http://two.mongoid.org/docs/upgrading.html

  # http://stackoverflow.com/a/9498372/2041969
  if File.exists?( old_pid_file )
    begin
      Process.kill( "QUIT", File.read( old_pid_file ).to_i )
    rescue Errno::ENOENT, Errno::ESRCH
      puts "Old master alerady dead"
    end
  end
end

after_fork do |server, worker|
  # uncomment for AR
  # ActiveRecord::Base.establish_connection
  
  # child process pids for monitoring if you need them
  child_pid_file = server.config[:pid].sub( '.pid', ".#{worker.nr}.pid" )
  system( "echo #{Process.pid} > #{child_pid_file}" )
end

