require_relative "lib/bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.playbook("playbooks/nginx-playbook.yml", ENV["TARGET_HOST"], {
      domain:        "ssl-index.dev",
      copy_index:    true,
      use_ssl:       true,
      email_address: "spec@example.com",
      country_name:  "US",
      org_name:      "Server Spec"
    })
  end
end

describe "Nginx config is valid" do
  include_examples "nginx", true
end

describe command("curl -ik https://ssl-index.dev") do
  include_examples("curl request", "200")
  include_examples("curl request html")

  it "responds with index.html" do
    expect(subject.stdout).to match /Nginx is serving content on ssl-index\.dev/
  end
end

describe "Request was logged" do
  include_examples("access logs", {code: "200", domain: "ssl-index.dev"})
end

describe command("echo | openssl s_client -showcerts -servername ssl-index.dev -connect ssl-index.dev:443 | openssl x509 -noout -text") do
  it "generated a certificate with correct params" do
    expect(subject.stdout).to match %r{/?CN\s*=\s*ssl-index\.dev}
    expect(subject.stdout).to match %r{DNS:ssl-index\.dev}
    expect(subject.stdout).to match %r{DNS:www\.ssl-index\.dev}
    expect(subject.stdout).to match %r{/?O\s*=\s*Server Spec}
    expect(subject.stdout).to match %r{/?emailAddress\s*=\s*spec@example.com}
  end
end

describe "www.* and HTTP requests are redirected" do
  include_examples("https redirect", "ssl-index.dev")
end
