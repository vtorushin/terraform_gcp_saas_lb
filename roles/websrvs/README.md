inst_nginx_Nvhosts
=========

The role installs nginx on all servers from the inventory file hosts.yml and installs n-virtualhosts from the vhosts variable.

Requirements
------------

* Add names to the virtualhosts variable.
* The servers in the hosts.yml file must be pre-installed with CentOS.
* Add the necessary Centos servers to the hosts.yml file.


Role Variables
--------------

Nginx web server options:
```yml
worker_conn: (defaults:1024)
bucket_size: (defaults:64)
```
Vhosts names:
```yml
vhosts:
  -"website1.com"
  -"website2.com"
```
Service Directory Paths:

```yml
work_dirs_paths:
  - "/etc/nginx/sites-available"
  - "/etc/nginx/sites-enabled"
```

Example Playbook
----------------

```yml
  name: Deploy Nginx and N-vhosts
  hosts: webservers
  become: yes
  roles:
    - inst_nginx_Nvhosts
```
         

Author Information
------------------

Denis Vtorushin
