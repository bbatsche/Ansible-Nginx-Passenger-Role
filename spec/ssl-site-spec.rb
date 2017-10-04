require_relative "lib/ansible_helper"
require_relative "bootstrap"
require_relative "shared/nginx"
require_relative "shared/redirect"

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

  it "instructs the browser to only use HTTPS" do
    expect(subject.stdout).to match /^Strict-Transport-Security: max-age=\d+; includeSubDomains; preload/
  end

  it "responds with index.html" do
    expect(subject.stdout).to match /Nginx is serving content on ssl-index\.dev/
  end
end

describe "Request was logged" do
  include_examples("access logs", {code: "200", domain: "ssl-index.dev"})
end

describe command("echo | openssl s_client -showcerts -servername ssl-index.dev -connect ssl-index.dev:443") do
  it "generated a certificate with out params" do
    expect(subject.stdout).to match %r{/CN=\*}
    expect(subject.stdout).to match %r{/O=Server Spec}
    expect(subject.stdout).to match %r{/emailAddress=spec@example.com}
  end
end

describe "www.* and HTTP requests are redirected" do
  include_examples("https redirect", "ssl-index.dev")
end
