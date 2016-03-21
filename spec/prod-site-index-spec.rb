require_relative "lib/ansible_helper"
require_relative "bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.instance.playbook("playbooks/nginx-playbook.yml", {
      domain:     "prod-index.dev",
      copy_index: true,
      env_name:   "prod"
    })
  end
end

describe "Nginx config is valid" do
  include_examples "nginx::config"
end

describe command("curl -i prod-index.dev") do
  it "sends a 200 OK response" do
    expect(subject.stdout).to match /^HTTP\/1\.1 200 OK$/
  end
end

describe command("curl prod-index.dev") do
  it "responds with index.html" do
    expect(subject.stdout).to match /Nginx is serving content on prod-index\.dev/
  end
end

describe command("tail -n 1 /var/log/nginx/prod-index.dev/static.log") do
  it "logged the previous request" do
    expect(subject.stdout).to match /^127\.0\.0\.1 - - \[[ 0-9a-zA-Z\/:+]+\] "GET \/ HTTP\/1\.1" 200 \d+ "-" "curl\/[0-9.]+"$/
  end
end
