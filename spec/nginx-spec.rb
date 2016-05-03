require_relative "lib/ansible_helper"
require_relative "bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.instance.playbook "playbooks/nginx-playbook.yml"
  end
end

describe "Nginx config is valid" do
  include_examples "nginx::config"
end

describe command("nginx -V") do
  it "has error and access logs set correctly" do
    expect(subject.stderr).to match /--http-log-path=\/var\/log\/nginx\/access\.log/
    expect(subject.stderr).to match /--error-log-path=\/var\/log\/nginx\/error\.log/
  end

  it "has Phusion Passenger enabled" do
    expect(subject.stderr).to match /--add-module=[a-zA-Z0-9._\-\/]+passenger\/src\/nginx_module/
  end
end

describe service('nginx') do
  it { should be_running }
end

describe port(80) do
  it { should be_listening.with('tcp') }
end

describe command('curl 127.0.0.1') do
  it "sends an empty response" do
    expect(subject.stderr).to match /Empty reply from server/
  end
end

describe command("tail -n 1 /var/log/nginx/access.log") do
  it "logged the previous request" do
    expect(subject.stdout).to match /^127\.0\.0\.1 - - \[\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\+\d\d:\d\d\] "GET \/ HTTP\/1\.1" 444 0 "-" "curl\/[0-9.]+" "-"$/
  end
end

describe file("/etc/nginx/nginx.conf") do
  it "has sendfile turned off" do
    expect(subject.content).to match /^\s+sendfile\s+off;$/
  end
end
