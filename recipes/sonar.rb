#
# Cookbook Name:: sonarqube
# Recipe:: sonar
#
# Copyright (C) 2014 Ryan Hass
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'uri'

pkg_name = "sonar_#{node['sonarqube']['version']}_all.deb"

# The use of the apt_repository is deprecated. This is here to ensure
# we gracefully clean up after ourselves when an older version of the 
# cookbook was originally in use.
apt_repository 'sonarqube' do
  action :remove
end

apt_preference 'sonar' do
  action :remove
end

remote_file ::File.join(Chef::Config[:file_cache_path], pkg_name) do
  source URI.join(node['sonarqube']['pkg']['uri'], pkg_name).to_s
  checksum node['sonarqube']['pkg']['checksum']
end

dpkg_package 'sonar' do
  source ::File.join(Chef::Config[:file_cache_path], pkg_name)
end

template ::File.join(node['sonarqube']['path'], 'conf', 'sonar.properties') do
  source 'sonar.properties.erb'
  owner 'sonar'
  group 'adm'
  mode 0644
  action :create
  notifies :reload, "service[sonar]", :delayed
end

template ::File.join(node['sonarqube']['path'], 'conf', 'wrapper.conf') do
  source 'wrapper.conf.erb'
  owner 'sonar'
  group 'adm'
  mode 0644
  action :create
  notifies :reload, "service[sonar]", :delayed
end

service 'sonar' do 
  action [:enable, :start]
end
