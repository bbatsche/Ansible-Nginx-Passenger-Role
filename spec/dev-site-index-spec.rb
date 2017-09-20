require_relative "lib/ansible_helper"
require_relative "bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.playbook("playbooks/nginx-playbook.yml", ENV["TARGET_HOST"], {
      domain:     "dev-index.dev",
      copy_index: true
    })
  end
end

describe "Nginx config is valid" do
  include_examples "nginx::config"
end

describe command("curl -i dev-index.dev") do
  it "sends a 200 OK response" do
    expect(subject.stdout).to match /^HTTP\/1\.1 200 OK$/
  end

  it "responds with index.html" do
    expect(subject.stdout).to match /Nginx is serving content on dev-index\.dev/
  end
end
