require_relative "lib/bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.playbook("playbooks/nginx-playbook.yml", ENV["TARGET_HOST"], {
      domain:     "add-config.test",
      copy_index: true,
      nginx_configs: ["external-config.conf"]
    })
  end
end

describe "Nginx config is valid" do
  include_examples "nginx"
end

describe command("curl -i add-config.test") do
  include_examples("curl request", "200")
  include_examples("curl request html")

  it "includes our external config" do
    expect(subject.stdout).to match /^X-Spec-Config: spec-config-exists/
  end
end
