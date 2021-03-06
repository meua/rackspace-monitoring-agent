# Host Info check documentation

## What are hostinfo checks?

Host information checks are a special class of checks that are used to fetch data on demand.   
The normal checks at root/checks are tied to the larger Rackspace monitoring eco-systems alarming and alerting features and are automatically scheduled.  
Host info calls mainly differ from checks in the sense that they can't be scheduled and alarmed on.

## Why hostinfo checks?

So what are they good for?  
They're great for fetching data on demand.  
Which is great if you want to pipe data about the host to other services or applications.  
Or have something it makes sense to occasionally check, perhaps support wants to narrow down a problem.  
Or we can use them to periodically fetch data about large clusters of servers with the granularity of  
individual computers for things like information dashboards built with Kibana, or service helper software that generate 
opinions/suggestions based on the status of a system or information support technicians usually require.  
There are also more hostinfo checks than regular checks and creating and integrating a hostinfo check is theoretically  
easier than creating and integrating a normal check into the rackspace monitoring ecosystem.  

## Remote API

You can run hostinfos through the rackspace monitoring systems API, remotely. 
You can make a curl request:
```sh
curl -H 'X-Auth-Token: <auth token>' -H 'X-Tenant-Id: <tenant id>'  https://monitoring.api.rackspacecloud.com/v1.0/agents/<agent_id>/host_info/<hostinfo_type>
```
Of course the above method can also be salvaged to programmatically allow usage from a user written script since all it 
does is use the Rackspace monitoring API.  
Other tools which wrap the Rackspace monitoring API like SDKs or CLIs should also theoretically be usable for this scenario.
E.g. The [rackspace monitoring cli](https://github.com/racker/rackspace-monitoring-cli) has a 
[raxmon-agent-host-info command](https://github.com/racker/rackspace-monitoring-cli/blob/master/commands/raxmon-agent-host-info)

## Debugging

You can run the monitoring agent from the command line if you're SSHd into the server and you want to check on the output. 
Great for debugging. Uses the [hostinfo_runner](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/runners/hostinfo_runner.lua).  
Caveats: 
  - run these commands with sudo since the agent usually has super user privileges
      when run via the monitoring system
  - The first line ({"Debug":{"InfoType":"<Type>", "OS":"<OS>"}}) is generated by the debug info generating function and will not exist in real output
  
Examples:  
  1. Run a single hostinfo and get output in the console
  ```sh
  rackspace-monitoring-agent -e hostinfo_runner -x <hostinfo type>
  ```
  or pipe it through [jq](https://stedolan.github.io/jq/) if you have it installed to get prettified colored output. The output is or should be valid json.  
  ```sh
  apt-get install jq
  rackspace-monitoring-agent -e hostinfo_runner -x packages | jq .
  ```

  2. You can also write them to a file instead of command line output  
  ```
  rackspace-monitoring-agent -e hostinfo_runner -x packages -f packages-debug.txt
  ```
  
  3. Run all hostinfo checks and write the output into a folder  
  ```
  rackspace-monitoring-agent -e hostinfo_runner -a -F debug
  ```
  
  4. Run all hostinfos and render debug to a single file:  
  ```
  rackspace-monitoring-agent -e hostinfo_runner -a -f debug.txt
  ```
  
  5. Debug info from all the hostinfos as console output  
  ```
  rackspace-monitoring-agent -e hostinfo_runner -a
  ```

  6. The -t flag will print all the possible hostinfo types  
  ```
  rackspace-monitoring-agent -e hostinfo_runner -t
  ```
  
  7. The -d flag will get us the unordered list in the following section minus the comments, must be supplied a foldername with the -F flag  
  ```
  rackspace-monitoring-agent -e hostinfo_runner -d -F debug
  ```
  
  8. The -T flag will benchmark all the hostinfos and return a list of hostinfos and their run times derived using luas os.clock util.
  ```
  rackspace-monitoring-agent -e hostinfo_runner -T
  ```
  
  9. The -S flag will benchmark output file sizes of all hostinfos and return a list thereof. Be forewarned that this isn't very accurate since data returned varies greatly depending on host configuration  
  ```
  rackspace-monitoring-agent -e hostinfo_runner -S
  ```

## Current list of available hostinfo checks

The best resource for figuring out the most up-to-date list of available hostinfos is to look at [all.lua](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/all.lua)

As of this writing, here is the list: (Generated using debugging examples #3 and #7 above.)
The items in the list are linked to sample debug output for themselves. 

- [CONNECTIONS](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/CONNECTIONS.json)  
  Runs arp -an and netstate -naten and gets us info about any open listening ports we have and any connections on them
- [IPTABLES](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/IPTABLES.json)  
  Runs iptables -S to get us info about our ipv4 policies
- [IP6TABLES](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/IP6TABLES.json)  
  Same as iptables but for ipv6
- [AUTOUPDATES](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/AUTOUPDATES.json)  
  Checks if autoupdates are enabled on a rhel or debian derivative linux distro
- [PASSWD](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/PASSWD.json)  
  Reads /etc/passwd then runs passwd -S for every user in it. Gets us some password related data
- [PAM](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/PAM.json)  
  Reads /etc/pam.d and gets us information about our pluggable authentication modules
- [CRON](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/CRON.json)  
  Reads files in the crontabs directory and fetches us info about scheduled cron jobs
- [KERNEL_MODULES](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/KERNEL_MODULES.json)  
  Reads the /proc/modules virtual directory and gets us info about modules loaded into the kernel
- [CPU](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/CPU.json)  
  Uses Sigar to retrieve information about the hosts CPU
- [DISK](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/DISK.json)  
  Uses Sigar to retrieve information about the hosts harddisks
- [FILESYSTEM](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/FILESYSTEM.json)  
  Uses Sigar to retrieve information about the hosts filesystem
- [LOGIN](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/LOGIN.json)  
  Reads /etc/login.defs and retrieves data about the login shell
- [MEMORY](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/MEMORY.json)  
  Uses Sigar to retrieve information about the hosts memory
- [NETWORK](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/NETWORK.json)  
  Uses Sigar to retrieve information about the hosts network interface
- [NIL](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/NIL.json)  
  Returns nil
- [PACKAGES](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/PACKAGES.json)  
  Runs either dpkg-query or rpm -qa and retrieves a list of package names and versions
- [PROCS](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/PROCS.json)  
  Uses Sigar to retrieve information about processes running on the host
- [SYSTEM](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/SYSTEM.json)  
  Uses Sigar to retrieve information about the host systems OS
- [WHO](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/WHO.json)  
  Uses Sigar to get information about the user, device, time and host
- [DATE](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/DATE.json)  
  Get date and time on host
- [SYSCTL](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/SYSCTL.json)  
  Runs sysctl -A and retrieves all possible key value pairs or kernel parameters that can be set at runtime
- [SSHD](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/SSHD.json)  
  Runs sshd -T and retrieves the openSSH daemons configuration parameters
- [FSTAB](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/FSTAB.json)  
  Reads /etc/fstab and retrieves information about the hosts file systems table. Fetches less, more targeted information compared to filesystem
- [FILEPERMS](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/FILEPERMS.json)  
  Reads a pre-specified list of files and checks and retrieves their permissions. Look at the fileperms.lua file to see the list of files checked
- [SERVICES](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/SERVICES.json)  
  Reads a few folders and files and generates a list of startup services. services.lua L28-L35 list the places read
- [DELETED_LIBS](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/DELETED_LIBS.json)  
  Greps through the output of lsof -nnP to retrieve a list of processes using deleted libs that no longer exist on the host  
- [CVE](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/CVE.json)  
  Gets a uniqued sorted list of common vulnerabilities and exposures that have been patched on the host system
- [LAST_LOGINS](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/LAST_LOGINS.json)  
  Runs last to get information about previous logins, current logged in user, bootups and when 'last' started logging.
- [REMOTE_SERVICES](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/REMOTE_SERVICES.json)  
  Runs netstat -tlpen to get a list of active internet connections to servers and underlying programs using them. 
- [IP4ROUTES](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/IP4ROUTES.json)  
  Runs netstat -nr4 and retrieves information about the kernels ip4 routing table
- [IP6ROUTES](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/IP6ROUTES.json)  
  Same as above but for ipv6 routing tables
- [APACHE2](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/APACHE2.json)  
  Uses a few different methods to retrieve information about the hosts Apache2 instance and installation if it exists
- [FAIL2BAN](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/FAIL2BAN.json)  
  Uses a few different methods to retrieve information about the hosts fail2ban instance and installation
- [LSYNCD](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/LSYNCD.json)
  Checks the status of the live syncing daemon or lsyncd
- [NGINX_CONFIG](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/NGINX_CONFIG.json)
  Returns vhosts, version, includes, status (0 if everything is ok when nginx -t is run), configuration path, prefix and configure arguments for local nginx 
- [WORDPRESS](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/WORDPRESS.json)  
  Checks Apache vhosts and retrieves data about any wordpress instances version and plugins  
- [MAGENTO](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/MAGENTO.json)  
  Returns the path, version and edition of local magento instances found via the apache2 and nginx configs  
- [PHP](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/PHP.json)  
  Returns information such as version, type (HHVM/PHP), and errors about php. Use the CLI and log files to extract this information  
- [POSTFIX](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/POSTFIX.json)  
  Checks the status of the postfix mail server  
- [HOSTNAME](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/debug/HOSTNAME.json)  
  Returns the hostname  
  
## Notes for developers

PRs are always welcome. Few tips:  
There's currently three over-arching classes of hostinfo checks.  
Those that read files, these use the read function in hostinfo/misc.lua  
Those that spawn shell commands to retrieve data, these use the run function in [hostinfo/misc.lua](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/hostinfo/misc.lua)  
The last type use a library called [Sigar (System Information Gatherer And Reporter)](https://github.com/hyperic/sigar)  
 which has an invaluable API for efficiently retrieving system information for things like RAM and CPU usage.  
There are some hostinfos that straddle classes as well.  

The hostinfos that use run or read have a streaming interface, with a readStream or childStream being passed to a transform stream which parses and collects data.  
The parsers or transform streams have tests specified in the section below.  

A common question that arises is why lua?
One of the main reasons behind it is that the [luvit](https://luvit.io/) framework we use allows us to do blazing fast async i/o and 
offers an API similiar to node, which allows luvit developers to use pre-existing node docs and community questions to their own benefit.   
The other reason is that lua is cross platform and works on embedded devices and due to use therein has been optimized to leave a very small footprint 

## Tests

To test only the hostinfos you can run the test runner from the root dir with an environment variable like so: 
```sh
TEST_MODULE=hostinfo make test
```
Host info tests are specified in [tests/test-hostinfo.lua](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/blob/master/tests/test-hostinfo.lua)  
The inputs and outputs are specified in [static/tests/hostinfo](https://github.com/virgo-agent-toolkit/rackspace-monitoring-agent/tree/master/static/tests/hostinfo)  
