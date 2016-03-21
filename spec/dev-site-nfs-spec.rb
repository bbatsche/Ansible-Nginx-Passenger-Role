require_relative "lib/ansible_helper"
require_relative "bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.instance.playbook("playbooks/nginx-playbook.yml", {
      domain:    "dev-nfs.dev",
      http_root: "/srv/http-nfs"
    })
  end
end

describe "Nginx config is valid" do
  include_examples "nginx::config"
end

describe command("curl -i dev-nfs.dev") do
  it "sends a 200 OK response" do
    expect(subject.stdout).to match /^HTTP\/1\.1 200 OK$/
  end
end

describe command("curl dev-nfs.dev") do
  it "responds with directory index" do
    expect(subject.stdout).to match /Index of \//
  end
end
