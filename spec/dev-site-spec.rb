require_relative "lib/ansible_helper"
require_relative "bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.playbook "playbooks/nginx-playbook.yml", ENV["TARGET_HOST"], domain: "test.dev"
  end
end

describe "Nginx config is valid" do
  include_examples "nginx::config"
end

describe command("curl -i test.dev") do
  it "sends a 200 OK response" do
    expect(subject.stdout).to match /^HTTP\/1\.1 200 OK$/
  end

  it "tells IE to use the latest version" do
    expect(subject.stdout).to match /^X-UA-Compatible: IE=Edge$/
  end

  it "disallows other sites from embedding in a frame" do
    expect(subject.stdout).to match /^X-Frame-Options: SAMEORIGIN$/
  end

  it "disallows content type sniffing" do
    expect(subject.stdout).to match /^X-Content-Type-Options: nosniff$/
  end

  it "enables IE's XSS script protection" do
    expect(subject.stdout).to match /^X-XSS-Protection: 1; mode=block$/
  end

  it "disables cache transforms" do
    expect(subject.stdout).to match /^Cache-Control: no-transform$/
  end

  it "responds with directory index" do
    expect(subject.stdout).to match /Index of \//
  end
end
