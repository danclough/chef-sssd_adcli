#
# Cookbook Name:: sssd_adcli
# Recipe:: join
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

include_recipe 'chef-vault::default'

begin
  bind_credentials = chef_vault_item(
    node['sssd_adcli']['adcli']['vault_name'],
    node['sssd_adcli']['adcli']['vault_item']
  )
rescue
  Chef::Log.warn(
    "Unable to load credentials from chef-vault item #{node['sssd_adcli']['adcli']['vault_name']}/#{node['sssd_adcli']['adcli']['vault_item']}. Skipping domain join."
  )
end

if bind_credentials
  execute "join domain #{node['sssd_adcli']['realm']}" do
    command "adcli join -U #{bind_credentials['username']}"\
            " #{node['sssd_adcli']['realm']}"
    input bind_credentials['password']
    not_if "getent group 'Domain Admins'"
  end
end
