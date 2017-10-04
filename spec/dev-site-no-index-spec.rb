require_relative "lib/ansible_helper"
require_relative "bootstrap"
require_relative "shared/nginx"
require_relative "shared/redirect"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.playbook "playbooks/nginx-playbook.yml", ENV["TARGET_HOST"], domain: "test.dev"
  end
end

describe "Nginx config is valid" do
  include_examples "nginx"
end

describe command("curl -i test.dev") do
  include_examples("curl request", "200")

  it "responds with directory index" do
    expect(subject.stdout).to match /Index of \//
  end
end

describe "Request was logged" do
  include_examples("access logs", {code: "200", domain: "test.dev"})
end

describe "www.* requests are redirected" do
  include_examples("www redirect", "test.dev")
end
