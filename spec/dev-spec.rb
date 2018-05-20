require_relative "lib/bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.playbook "playbooks/nginx-playbook.yml"
  end
end

describe "Nginx config is valid" do
  include_examples "nginx"
end

describe command('curl 127.0.0.1') do
  it "sends an empty response" do
    expect(subject.stderr).to match /Empty reply from server/
  end
end

describe "Request was logged" do
  include_examples("access logs", code: "444")
end

describe file("/etc/nginx/nginx.conf") do
  it "has sendfile turned off" do
    expect(subject.content).to match /^\s+sendfile\s+off;$/
  end
end
