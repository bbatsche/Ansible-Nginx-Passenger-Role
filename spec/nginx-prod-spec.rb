require_relative "lib/ansible_helper"
require_relative "bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.instance.playbook "playbooks/nginx-playbook.yml", env_name: "production"
  end
end

describe "Nginx config should be valid" do
  include_examples "nginx::config"
end

describe file("/etc/nginx/nginx.conf") do
  its(:content) { should match /^\s+sendfile\s+on;$/ }
end
