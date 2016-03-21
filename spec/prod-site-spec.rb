require_relative "lib/ansible_helper"
require_relative "bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.instance.playbook("playbooks/nginx-playbook.yml", {
      domain:   "prod.dev",
      env_name: "prod"
    })
  end
end

describe "Nginx config is valid" do
  include_examples "nginx::config"
end

describe command("curl -i prod.dev") do
  it "sends a 403 Forbidden response" do
    expect(subject.stdout).to match /^HTTP\/1\.1 403 Forbidden$/
  end
end
