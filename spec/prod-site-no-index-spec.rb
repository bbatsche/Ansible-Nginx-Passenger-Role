require_relative "lib/bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.playbook("playbooks/nginx-playbook.yml", ENV["TARGET_HOST"], {
      domain:   "prod.dev",
      env_name: "prod"
    })
  end
end

describe "Nginx config is valid" do
  include_examples "nginx"
end

describe command("curl -I prod.dev") do
  include_examples("curl request", "403")
end

describe "www.* requests are redirected" do
  include_examples("www redirect", "prod.dev")
end
