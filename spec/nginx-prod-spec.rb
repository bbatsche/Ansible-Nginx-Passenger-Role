require_relative "lib/ansible_helper"
require_relative "bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.playbook "playbooks/nginx-playbook.yml", ENV["TARGET_HOST"], env_name: "production"
  end
end

describe "Nginx config is valid" do
  include_examples "nginx::config"
end

describe file("/etc/nginx/nginx.conf") do
  it "has sendfile turned on" do
    expect(subject.content).to match /^\s+sendfile\s+on;$/
  end
end
