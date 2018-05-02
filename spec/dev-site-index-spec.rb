require_relative "lib/bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.playbook("playbooks/nginx-playbook.yml", ENV["TARGET_HOST"], {
      domain:     "dev-index.dev",
      copy_index: true
    })
  end
end

describe "Nginx config is valid" do
  include_examples "nginx"
end

describe command("curl -i dev-index.dev") do
  include_examples("curl request", "200")
  include_examples("curl request html")

  it "responds with index.html" do
    expect(subject.stdout).to match /Nginx is serving content on dev-index\.dev/
  end
end

describe "Request was logged" do
  include_examples("access logs", {code: "200", domain: "dev-index.dev"})
end

describe "www.* requests are redirected" do
  include_examples("www redirect", "dev-index.dev")
end
