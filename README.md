Ansible Nginx Passenger Role
============================

[![Build Status](https://travis-ci.org/bbatsche/Ansible-Nginx-Passenger-Role.svg)](https://travis-ci.org/bbatsche/Ansible-Nginx-Passenger-Role) [![Ansible Galaxy](https://img.shields.io/ansible/role/7334.svg)](https://galaxy.ansible.com/bbatsche/Nginx)

This role will install Nginx server along with Phusion Passenger bindings for serving Node, Python, or Ruby. It can also setup and configure a site for a given domain.

Requirements
------------

This role takes advantage of Linux filesystem ACLs and a group called "web-admin" for granting access to particular directories. You can either configure those steps manually or install the [`bbatsche.Base`](https://galaxy.ansible.com/bbatsche/Base/) role.

Role Variables
--------------

- `env_name` &mdash; Whether this server is in a "development", "production", or other type of environment. Default is "dev"
- `http_root` &mdash; Where site directores should be created. Default is "/srv/http"
- `max_upload_size` &mdash; Maximum upload size in MB. Default is "10"
- `domain` &mdash; Domain name for site to create. Undefined by default.
- `site_type` &mdash; Application server software this site uses. Default is none. Possible values are:
    - hhvm
    - node
    - php
    - python
    - ruby
- `copy_index` &mdash; Copy an index.html stub to the site. Default is no.

Example Playbook
----------------

```yml
- hosts: servers
  roles:
     - { role: bbatsche.Nginx, domain: my-test-domain.dev, site_type: ruby }
```

License
-------

MIT

Testing
-------

Included with this role is a set of specs for testing each task individually or as a whole. To run these tests you will first need to have [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) installed. The spec files are written using [Serverspec](http://serverspec.org/) so you will need Ruby and [Bundler](http://bundler.io/).

To run the full suite of specs:

```bash
$ gem install bundler
$ bundle install
$ rake
```

The spec suite will target both Ubuntu Trusty Tahr (14.04) and Xenial Xerus (16.04).

To see the available rake tasks (and specs):

```bash
$ rake -T
```

These specs are **not** meant to test for idempotence. They are meant to check that the specified tasks perform their expected steps. Idempotency is tested independently via integration testing.
