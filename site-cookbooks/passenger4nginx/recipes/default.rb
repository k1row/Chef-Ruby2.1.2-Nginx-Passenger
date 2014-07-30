#
# Cookbook Name:: passenger4nginx
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# --- Install nginx ---

# First, remove unneeded packages
%w{ nginx nginx-light nginx-full nginx-extras }.each do |pkg|
  package pkg do
    action :remove
  end
end

# Install passenger
gem_package 'passenger' do
  action :upgrade
  gem_binary '/usr/bin/gem2.0'
  version node[:nginx][:passenger][:version]
end

remote_file 'download nginx' do
  action :create_if_missing
  owner 'root'
  group 'root'
  mode '0644'
  path "/usr/src/nginx-#{node[:nginx][:version]}.tar.gz"
  source "http://nginx.org/download/nginx-#{node[:nginx][:version]}.tar.gz"
end

execute 'extract nginx' do
  command "tar xvfz nginx-#{node[:nginx][:version]}.tar.gz"
  cwd '/usr/src'
  not_if do
    File.directory? "/usr/src/nginx-#{node[:nginx][:version]}"
  end
end

execute 'build nginx' do
  command "passenger-install-nginx-module" <<
    " --auto" <<
    " --prefix=/usr/local/nginx" <<
    " --nginx-source-dir=/usr/src/nginx-#{node[:nginx][:version]}" <<
    " --extra-configure-flags='--with-ipv6 --with-http_realip_module'"
  not_if do
  	File.exists?("/user/local/nginx") &&
    File.exists?("#{node[:nginx][:gem][:path]}/passenger-#{node[:nginx][:passenger][:version]}/agents/PassengerWatchdog")
  end
end

# Setup nginx environment
link "/etc/nginx" do
  to "/usr/local/nginx/conf"
end

link '/var/log/nginx' do
  to "/usr/local/nginx/logs"
end

directory "/etc/nginx/conf.d" do
  owner "root"
  group "root"
end

# Configuration files
template "nginx.conf" do
	path "/etc/nginx/nginx.conf"
	source "nginx.conf.erb"
	owner "root"
	group "root"
	mode 0644
	notifies :reload,'service[nginx]'
end

template "server.conf.erb" do
	path "/etc/nginx/conf.d/server.conf"
	source "server.conf.erb"
	owner "root"
	group "root"
	mode 0644
	notifies :reload,'service[nginx]'
end

# Setup init script
cookbook_file "/etc/init.d/nginx" do
  source "nginx"
  mode 0755
  not_if "ls /etc/init.d/nginx"
  notifies :run, "execute[chkconfig add nginx]"
end

# Setup chkconfing
execute 'chkconfig add nginx' do
  action :nothing
  command "chkconfig --add nginx"
  notifies :run, "execute[chkconfig nginx on]"
  notifies :start, "service[nginx]"
end

execute 'chkconfig nginx on' do
  action :nothing
  command "chkconfig nginx on"
end

service "nginx" do
  action :nothing
end
