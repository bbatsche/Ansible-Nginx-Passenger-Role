require_relative "lib/ansible_helper"
require_relative "bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.instance.playbook "playbooks/nginx-playbook.yml", domain: "test.dev"
  end
end

describe "Nginx config should be valid" do
  include_examples "nginx::config"
end

describe command('printf "GET / HTTP/1.1\nHost: test.dev\n\n" | nc 127.0.0.1 80') do
  # check headers
  its(:stdout) { should match /^+HTTP\/1\.1 200 OK$/ }
  its(:stdout) { should match /^X-UA-Compatible: IE=Edge$/ }
  its(:stdout) { should match /^X-Frame-Options: SAMEORIGIN$/ }
  its(:stdout) { should match /^X-Content-Type-Options: nosniff$/ }
  its(:stdout) { should match /^X-XSS-Protection: 1; mode=block$/ }
  its(:stdout) { should match /^Cache-Control: no-transform$/ }

  # server directory listing
  its(:stdout) { should match /Index of \// }
end
