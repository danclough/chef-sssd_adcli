# sssd_ad

This cookbook installs SSSD on a Debian-based system and configures it for Active Directory authentication, using the adcli utility to join the system to a domain if cnfigured to do so through the cookbook.

IMPORTANT: This cookbook assumes the system's FQDN (e.g. 'server.example.contoso.com') is in /etc/hosts. Joining the domain may fail if this is not the case. See the above link for details.

Platforms
---------
Tested on Debian and Ubuntu.

Attributes
-----------
- `['sssd_adcli']['workgroup']` - name of the default domain workgroup
- `['sssd_adcli']['realm']` - the domain realm URL
- `['sssd_adcli']['dc']` - the FQDN of the primary domain controller; defaults to nil.  If left undefined, Kerberos will be configured to lookup the PDC in DNS.
- `['sssd_adcli']['use_ntp']` - configure NTP to sync with the primary domain controller; defaults to false.
- `['sssd_adcli']['join']` - indicates to attempt to join the system to the domain if not already joined; defaults to false.  Requires credentials in a vault as listed below.
- `['sssd_adcli']['sssd']['access_filter']` - optional `ad_access_filter` for the joined domain, e.g. "`(&(sAMAccountName=jo*)(unixHomeDirectory=*))`"
- `['sssd_adcli']['sssd']['nss_filter_users']` - optional comma separated string of users to be excluded from the AD search; see `sssd.conf` man page
- `['sssd_adcli']['sssd']['cache_credentials']` - boolean to enable SSSD credential caching; defaults to false
- `['sssd_adcli']['sssd']['default_shell']` - the default shell assigned to all AD users.
- `['sssd_adcli']['sssd']['fallback_homedir']` - the fallback home directory path for all AD users if their configured home directory path is not available.
- `['sssd_adcli']['sssd']['override_homedir']` - a forced home directory path for all AD users, overriding any settings configured in AD.
- `['sssd_adcli']['sssd']['ad_maximum_machine_account_password_age']` - the interval at which SSSD should attempt to update the AD trust password.  If set to 0, SSSD will not automatically change the trust password and this must be done via cron with `net ads changetrustpw`.
- `['sssd_adcli']['sssd']['services']` - an hash of additional services to configure in the `sssd.conf` file.  Each hash entry will be parsed as a hash of key=>value pairs and translated directly into `sssd.conf` lines.  For instance, a hash of `"nss": { "filter_groups": "root" }` will generate the following block:
```
[nss]
filter_groups = root
```
- `['sssd_adcli']['adcli']['vault_name']` - name of the Chef Vault containing domain credentials.
- `['sssd_adcli']['adcli']['vault_item']` - name of the vault item containing domain credentials as `username` and `password` properties.

Usage
-----
Add the `sssd_adcli::default` recipe to the node's run list, and set the `['sssd_adcli']['workgroup']` and `['sssd_adcli']['realm']` attributes.  If desired, you may hardcode a domain controller using the `['sssd_adcli']['dc']` attribute. If the system should be joined to the domain automatically, set the `join_domain` attribute to true and create a chef-vault item containing AD credentials that have appropriate permissions.
