require_relative "lib/ansible_helper"
require_relative "bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.instance.playbook "playbooks/nginx-playbook.yml"
  end
end

describe "Nginx config should be valid" do
  include_examples "nginx::config"
end

describe command("nginx -V") do
  its(:stderr) { should match /--http-log-path=\/var\/log\/nginx\/access\.log/ }
  its(:stderr) { should match /--error-log-path=\/var\/log\/nginx\/error\.log/ }
  its(:stderr) { should match /--add-module=[a-zA-Z0-9._\-\/]+passenger\/src\/nginx_module/ }

  its(:exit_status) { should eq 0 }
end

describe service('nginx') do
  it { should be_running }
end

describe port(80) do
  it { should be_listening.with('tcp') }
end

describe command('printf "GET / HTTP/1.1\nHost: test.com\n\n" | nc 127.0.0.1 80') do
  its(:stdout) { should eq "" }

  its(:exit_status) { should eq 0 }
end

describe command("tail -n 1 /var/log/nginx/access.log") do
  its(:stdout) { should match /^127\.0\.0\.1 - - \[[ 0-9a-zA-Z\/:+]+\] "GET \/ HTTP\/1\.1" 444 0 "-" "-" "-"$/ }
end

describe file("/etc/nginx/nginx.conf") do
  its(:content) { should match /^\s+sendfile\s+off;$/ }
end
