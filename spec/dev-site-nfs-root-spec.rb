require_relative "lib/bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.playbook("playbooks/nginx-nfs-playbook.yml", ENV["TARGET_HOST"], {
      domain:    "dev-nfs.dev",
      http_root: "/srv/nfs/http"
    })
  end

  config.before :all do
    skip "Docker cannot export NFS shares" if AnsibleHelper[ENV["TARGET_HOST"]].is_a? DockerEnv
  end
end

describe "Nginx config is valid" do
  include_examples "nginx"
end

describe command("curl -i dev-nfs.dev") do
  include_examples("curl request", "200")

  it "responds with directory index" do
    expect(subject.stdout).to match /Index of \//
  end
end

describe "Request was logged" do
  include_examples("access logs", {code: "200", domain: "dev-nfs.dev"})
end

describe "www.* requests are redirected" do
  include_examples("www redirect", "dev-nfs.dev")
end
