Ansible Nginx Passenger Role
============================

[![Build Status](https://travis-ci.org/bbatsche/Ansible-Nginx-Passenger-Role.svg?branch=master)](https://travis-ci.org/bbatsche/Ansible-Nginx-Passenger-Role)

This role will install Nginx server along with Phusion Passenger bindings for serving Node, Python, or Ruby. It can also setup and configure a site for a given domain.

Role Variables
--------------

- `app_env` &mdash; Whether this server is in a "development", "production", or other type of environment. Default is "dev"
- `http_root` &mdash; Where site directores should be created. Default is "/srv/http"
- `domain` &mdash; Domain name for site to create. Undefined by default.
- `site_type` &mdash; Application server software site uses. Default is none. Possible values are:
    - hhvm
    - node
    - php
    - python
    - ruby
- `copy_index` &mdash; Copy an index.html stub to the site. Default is no.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

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

Included with this role is a set of specs for testing each task individually or as a whole. To run these tests you will first need to have [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) installed. The spec files are written using [Serverspec](http://serverspec.org/) so you will need Ruby and [Bundler](http://bundler.io/). _**Note:** To keep things nicely encapsulated, everything is run through `rake`, including Vagrant itself. Because of this, your version of bundler must match Vagrant's version requirements. As of this writing (Vagrant version 1.8.1) that means your version of bundler must be between 1.5.2 and 1.10.6._

To run the full suite of specs:

```bash
$ gem install bundler -v 1.10.6
$ bundle install
$ rake
```

To see the available rake tasks (and specs):

```bash
$ rake -T
```

There are several rake tasks for interacting with the test environment, including:

- `rake vagrant:up` &mdash; Boot the test environment (_**Note:** This will **not** run any provisioning tasks._)
- `rake vagrant:provision` &mdash; Provision the test environment
- `rake vagrant:destroy` &mdash; Destroy the test environment
- `rake vagrant[cmd]` &mdash; Run some arbitrary Vagrant command in the test environment. For example, to log in to the test environment run: `rake vagrant[ssh]`

These specs are **not** meant to test for idempotence. They are meant to check that the specified tasks perform their expected steps. Idempotency can be tested independently as a form of integration testing.

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
