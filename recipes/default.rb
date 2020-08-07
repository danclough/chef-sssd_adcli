#
# Cookbook Name:: sssd_adcli
# Recipe:: default
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Install packages
node['sssd_adcli']['packages'].each do |pkg|
  package pkg.to_s do
    action :install
  end
end

# Configure Kerberos
template '/etc/krb5.conf' do
  source 'krb5.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

# Configure NTP
if node['sssd_adcli']['use_ntp'] and node['sssd_adcli']['dc']
  node.override['ntp']['servers'].append(node['sssd_adcli']['dc'])
  include_recipe 'ntp::default'
end

if node['sssd_adcli']['enable_mkhomedir']
  execute 'update PAM auth config' do
    command '/usr/sbin/pam-auth-update --package'
    action :nothing
  end
  cookbook_file '/usr/share/pam-configs/ad_mkhomedir' do
    source 'ad_mkhomedir'
    owner 'root'
    group 'root'
    mode '0644'
    notifies :run, 'execute[update PAM auth config]'
  end
end

# Join the domain if specified
include_recipe 'sssd_adcli::join' if node['sssd_adcli']['join']

# Install sssd config
template '/etc/sssd/sssd.conf' do
  source 'sssd.conf.erb'
  owner 'root'
  group 'root'
  mode '0600'
  # Restart the sssd service only if the server is bound to a domain
  notifies :restart, 'service[sssd]' if ::File.exist?('/etc/krb5.keytab')
end

service 'sssd' do
  supports restart: true
  if node['sssd_adcli']['join']
    action :enable # delay service start until binding
    subscribes :start, "execute[join domain #{node['sssd_adcli']['realm']}]"
  else
    action [:start, :enable]
  end
end

