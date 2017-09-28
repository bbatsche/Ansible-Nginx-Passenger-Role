require_relative "lib/ansible_helper"
require_relative "bootstrap"
require_relative "shared/nginx"

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

describe command("curl -i prod.dev") do
  include_examples("curl request", "403")
end
