#
# Cookbook Name:: sssd_adcli
# Attributes:: default
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

default['sssd_adcli']['workgroup'] = 'CONTOSO'
default['sssd_adcli']['realm'] = 'EXAMPLE.CONTOSO.COM'
#default['sssd_adcli']['dc'] = nil
default['sssd_adcli']['use_ntp'] = false
default['sssd_adcli']['enable_mkhomedir'] = false
default['sssd_adcli']['join'] = false
default['sssd_adcli']['adcli']['vault_name'] = 'vault'
default['sssd_adcli']['adcli']['vault_item'] = 'sssd_adcli'

#default['sssd_adcli']['sssd']['access_filters'] = nil
default['sssd_adcli']['sssd']['cache_credentials'] = false
default['sssd_adcli']['sssd']['nss_filter_users'] = false
default['sssd_adcli']['sssd']['fallback_homedir'] = '/home/%d/%u'
default['sssd_adcli']['sssd']['default_shell'] = '/bin/bash'

default['sssd_adcli']['packages'] = %w(sssd-ad adcli)

case node['platform_family']
when 'debian'
    default['sssd_adcli']['packages'] << 'krb5-user'
when 'rhel'
    default['sssd_adcli']['packages'] << 'krb5-workstation'
end
