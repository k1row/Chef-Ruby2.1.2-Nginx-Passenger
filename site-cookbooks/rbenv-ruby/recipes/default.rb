#
# Cookbook Name:: rbenv-ruby
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'git'

%w(gcc openssl-devel readline-devel ruby-devel).each do |pkg|
  package pkg do
    action :install
  end
end

git "/usr/local/rbenv" do
  not_if "test -d #{name}"
  repository "git://github.com/sstephenson/rbenv.git"
  reference  "master"
  revision   node[:rbenv][:revision]
  action     :checkout
  user       "root"
  group      "root"
end

directory "/usr/local/rbenv/plugins" do
  owner  "root"
  group  "root"
  mode   "0755"
  action :create
end

template "/etc/profile.d/rbenv.sh" do
  owner "root"
  group "root"
  mode  0644
end

git "/usr/local/rbenv/plugins/ruby-build" do
  not_if "test -d #{name}"
  repository "git://github.com/sstephenson/ruby-build.git"
  reference  "master"
  revision   node[:ruby_build][:revision]
  action     :checkout
  user       "root"
  group      "root"
end

execute "install ruby" do
  not_if "source /etc/profile.d/rbenv.sh; rbenv versions | grep #{node[:rbenv][:build]}"
  command "source /etc/profile.d/rbenv.sh; CONFIGURE_OPTS=\"--with-readline-dir=/usr/include/readline\" rbenv install #{node[:rbenv][:build]}"
  action :run
end

execute "install bundler" do
  not_if "source /etc/profile.d/rbenv.sh; rbenv shell #{node[:rbenv][:build]}; gem list | grep bundler"
  command "source /etc/profile.d/rbenv.sh; rbenv shell #{node[:rbenv][:build]}; gem i bundler -v '#{node[:rbenv][:bundler]}' --no-ri --no-rdoc; rbenv rehash"
  action :run
end

execute "set ruby version" do
  command "source /etc/profile.d/rbenv.sh; rbenv global #{node[:rbenv][:build]}; rbenv rehash"
  action :run
end

bash "insert_rbenv_line" do
  user "root"
  code <<-EOS
  echo 'export RBENV_ROOT="/usr/local/rbenv"' >> /etc/profile
  echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile
  echo 'eval "$(rbenv init -)"' >> /etc/profile
  source /etc/profile
  EOS
end
