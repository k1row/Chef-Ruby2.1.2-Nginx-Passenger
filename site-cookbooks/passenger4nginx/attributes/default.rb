default[:nginx][:worker_processes] = 1
default[:nginx][:worker_connections] = 1024
default[:nginx][:worker_rlimit_nofile] = node[:nginx][:worker_processes] * node[:nginx][:worker_connections]
default[:nginx][:pid] = "/var/run/nginx.pid"
default[:nginx][:log_dir] = "/var/log/nginx"
default[:nginx][:error_log_level] = "crit"
default[:nginx][:redirect_ssl] = false
default[:nginx][:keepalive_timeout] = 10

default[:nginx][:port] = 80
default[:nginx][:server_name] = "54.92.87.182"
default[:nginx][:root] = "/tmp/airt-server/current/public"

default[:nginx][:version] = "1.4.7"

default[:nginx][:passenger][:version] = "4.0.48"
default[:nginx][:passenger][:root] = "/usr/local/share/ruby/gems/2.0/gems"
default[:nginx][:passenger][:ruby] = "/usr/local/rbenv/versions/2.1.2/bin/ruby"
