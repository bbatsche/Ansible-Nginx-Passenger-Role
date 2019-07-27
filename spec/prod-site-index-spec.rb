require_relative "lib/bootstrap"
require "date"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.playbook("playbooks/nginx-playbook.yml", ENV["TARGET_HOST"], {
      domain:     "prod-index.dev",
      copy_index: true,
      env_name:   "prod"
    })
  end
end

describe "Nginx config is valid" do
  include_examples "nginx"
end

describe command("curl -i prod-index.dev") do
  include_examples("curl request", "200")
  include_examples("curl request html")
  include_examples("curl request cache", 0)

  it "responds with index.html" do
    expect(subject.stdout).to match /Nginx is serving content on prod-index\.dev/
  end
end

describe "Request was logged" do
  include_examples("access logs", {code: "200", domain: "prod-index.dev"})
end

describe command("curl -I prod-index.dev/test.css") do
  include_examples("curl request", "200")
  include_examples("curl request cache", 365)
end

describe command("curl -I prod-index.dev/test.js") do
  include_examples("curl request", "200")
  include_examples("curl request cache", 365)
end

describe command("curl -I prod-index.dev/test.jpg") do
  include_examples("curl request", "200")
  include_examples("curl request cache", 30)
end

describe "www.* requests are redirected" do
  include_examples("www redirect", "prod-index.dev")
end
