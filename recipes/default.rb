#
# Cookbook Name:: chef-authldap
# Recipe:: default
#
# Copyright (C) 2014 Leonard TAVAE
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

%w(libpam-ldapd libnss-ldapd unscd nslcd).each do |package|
  package package do
    action :install
  end
end

directory node['chef-authldap']['home_path'] do
  owner 'root'
  group 'root'
  mode '0644'
  recursive true
  action :create
end

# static files upload

cookbook_file '/etc/pam.d/common-session' do
  source 'common-session'
  owner 'root'
  group 'root'
  mode '0644'
end

cookbook_file '/etc/nsswitch.conf' do
  source 'nsswitch.conf'
  owner 'root'
  group 'root'
  mode '0644'
end

# dynamic template

template '/etc/nslcd.conf' do
  source 'nslcd.conf.erb'
  owner 'root'
  group 'root'
  mode '0640'
  notifies :restart, 'service[nslcd]'
  notifies :restart, 'service[unscd]'
end

service 'nslcd' do
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end

service 'unscd' do
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end
