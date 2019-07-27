require_relative "lib/bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.playbook("playbooks/nginx-playbook.yml", ENV["TARGET_HOST"], {
      domain:     "csp-config.test",
      copy_index: true,
      content_security_policy: {
        "default-src": ["*"],
        "script-src": [
          "unsafe-inline",
          "unsafe-eval",
        ],
        "style-src": [],
        "img-src": [
          "self",
          "data:",
          "*.example.com"
        ],
        "font-src": [
          "none"
        ]
      }
    })
  end
end

describe "Nginx config is valid" do
  include_examples "nginx"
end

describe command("curl -i csp-config.test") do
  include_examples("curl request", "200")
  include_examples("curl request html")

  it "includes a custom CSP header" do
    expect(subject.stdout).to match /^Content-Security-Policy: default-src \*; script-src 'unsafe-inline' 'unsafe-eval'; style-src 'none'; img-src 'self' data: \*.example.com; font-src 'none'/i
  end
end
