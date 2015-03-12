# Capistrano Unicorn

Capistrano 3.x plugin that integrates Unicorn tasks into capistrano deployment script.
Taken from https://github.com/sosedoff/capistrano-unicorn and adapted to work with Capistrano 3.x.

[![Gem Version](https://badge.fury.io/rb/glebtv-capistrano-unicorn.svg)](http://badge.fury.io/rb/glebtv-capistrano-unicorn)

## Usage

### Setup

**Add the library to your `Gemfile`:**

```ruby
group :development do
  gem 'glebtv-capistrano-unicorn', :require => false
end
```

**Add it to `Capfile`:**

```ruby
require 'capistrano/unicorn'
```

**Add unicorn restart task hook:**

If your app IS NOT preloaded (preload_app false, default):

```ruby
after 'deploy:publishing', 'unicorn:reload'
```

If your app is preloaded (preload_app true): 

```ruby
after 'deploy:publishing', 'unicorn:restart'
```

If you have before_fork unicorn hook for zero downtime deployments installed (preload_app true + before_hook), best option:

```ruby
after 'deploy:publishing', 'unicorn:duplicate'
```

Create a new configuration file `config/unicorn.rb` or `config/unicorn/STAGE.rb`, 
where stage is your deployment environment.

## Example config 

Includes zero-downtime deployments

[examples/rails3.rb](https://github.com/glebtv/capistrano-unicorn/blob/master/examples/rails3.rb). 

Please READ all comments in the file if you are having problems.
If you use AR you need to uncomment two lines in the file.

Please refer to Unicorn documentation for more examples and configuration options.

### Deploy

First, make sure you're running the latest release:

```
cap production deploy
```

Then you can test each individual task:

```
cap production unicorn:start
cap production unicorn:stop
cap production unicorn:reload
```

## Configuration

You can modify any of the following Capistrano variables in your `deploy.rb` config.
You can use the `unicorn:show_vars` task to check that the values you have specified
are set correctly.

### Environment parameters

- `unicorn_env`             - Set basename of unicorn config `.rb` file to be used loaded from `unicorn_config_path`. Defaults to `rails_env` variable if set, otherwise `production`.
- `unicorn_rack_env`        - Set the value which will be passed to unicorn via [the `-E` parameter as the Rack environment](http://unicorn.bogomips.org/unicorn_1.html). Valid values are `development`, `deployment`, and `none`. Defaults to `development` if `rails_env` is `development`, otherwise `deployment`.

### Execution parameters

- `unicorn_user`            - Launch unicorn master as the specified user via `sudo`. Defaults to `nil`, which means no use of `sudo`, i.e. run as the user defined by the `user` variable.
- `unicorn_roles`           - Define which roles to perform unicorn recipes on. Defaults to `:app`.
- `unicorn_bundle`          - Set bundler command for unicorn. Defaults to `bundle`.
- `unicorn_bin`             - Set unicorn executable file. Defaults to `unicorn`.
- `unicorn_options`         - Set any additional options to be passed to unicorn on startup.
- `unicorn_restart_sleep_time` - Number of seconds to wait for (old) pidfile to show up when restarting unicorn. Defaults to 2.

### Relative path parameters

- `app_subdir`              - If your app lives in a subdirectory 'rails' (say) of your repository, set this to `/rails` (the leading slash is required).
- `unicorn_config_rel_path` - Set the directory path (relative to `app_path` - see below) where unicorn config files reside. Defaults to `config`.
- `unicorn_config_filename` - Set the filename of the unicorn config file loaded from `unicorn_config_path`. Should not be present in multistage installations. Defaults to `unicorn.rb`.

### Absolute path parameters

- `app_path`                - Set path to app root. Defaults to `current_path + app_subdir`.
- `unicorn_pid`             - Set unicorn PID file path. By default, attempts to auto-detect from unicorn config file. On failure, falls back to value in `unicorn_default_pid`
- `unicorn_default_pid`     - See above. Defaults to `#{current_path}/tmp/pids/unicorn.pid`
- `bundle_gemfile`          - Set path to Gemfile. Defaults to `#{app_path}/Gemfile`
- `unicorn_config_path`     - Set the directory where unicorn config files reside. Defaults to `#{current_path}/config`.

### Zero Downtime Deployment Options

* `unicorn:restart`: :-1: This can sort of support it with a configurable timeout, which may not be reliable.
* `unicorn:reload`: :question: Can anyone testify to its zero-downtime support?
* `unicorn:duplicate`: :+1: If you install the Unicorn `before_fork` hook, then yes! See: https://github.com/sosedoff/capistrano-unicorn/issues/40#issuecomment-16011353

## Available Tasks

To get a list of all capistrano tasks, run `cap -T`:

```
cap production unicorn:add_worker                # Add a new worker
cap production unicorn:remove_worker             # Remove amount of workers
cap production unicorn:reload                    # Reload Unicorn
cap production unicorn:restart                   # Restart Unicorn
cap production unicorn:show_vars                 # Debug Unicorn variables
cap production unicorn:shutdown                  # Immediately shutdown Unicorn
cap production unicorn:start                     # Start Unicorn master process
cap production unicorn:stop                      # Stop Unicorn
```

## License

See LICENSE file for details.
