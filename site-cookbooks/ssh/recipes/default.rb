#
# Cookbook Name:: ssh
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
user = node[:current_user]
home_dir = node[:etc][:passwd][user][:dir]
#if node[:environment] == nil and node[:system][:environment] != nil then
#  env_name = node[:system][:environment]
#else
#  env_name = node[:environment]
#end

#private_key = data_bag_item('ssh_private_keys',env_name)
private_key = data_bag_item('ssh_private_keys', 'development')
private_key["keys"].each do | name, value |
  template "#{home_dir}/.ssh/#{name}" do
    owner user
    group user
    mode 0600
    source 'key_file.erb'
    variables({
      :private_key => value
    })
  end
end

template "#{home_dir}/.ssh/config" do
  owner user
  group user
  mode 0600
  source 'config.erb'
  variables({
      :key_name => private_key["default_key"]
  })
end

public_key = data_bag_item('ssh_public_keys','default')
file "#{home_dir}/.ssh/authorized_keys" do
  owner user
  group user
  mode 0600

  _file = Chef::Util::FileEdit.new(path)
  public_key["keys"].each do | user, name |
    _file.insert_line_if_no_match("#{name}", "#{name}\n")
    _file.write_file
  end
end
