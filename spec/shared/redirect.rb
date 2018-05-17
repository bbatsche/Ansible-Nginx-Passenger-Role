require "serverspec"
require_relative "nginx"

shared_examples "www redirect" do |domain|
  describe command("curl -I www.#{domain}") do
    include_examples("curl request", "301")

    it "removed www from the domain" do
      expect(subject.stdout).to match %r{^[Ll]ocation: http://#{Regexp.quote(domain)}}
    end
  end
end

shared_examples "https redirect" do |domain|
  describe command("curl -I #{domain}") do
    include_examples("curl request", "301")

    it "redirected to the HTTPS site" do
      expect(subject.stdout).to match %r{^[Ll]ocation: https://#{Regexp.quote(domain)}}
    end
  end

  describe command("curl -I www.#{domain}") do
    include_examples("curl request", "301")

    it "redirected to the HTTPS site" do
      expect(subject.stdout).to match %r{^[Ll]ocation: https://#{Regexp.quote(domain)}}
    end
  end

  describe command("curl -Ik https://www.#{domain}") do
    include_examples("curl request", "301")

    it "removed www from the domain" do
      expect(subject.stdout).to match %r{^[Ll]ocation: https://#{Regexp.quote(domain)}}
    end
  end
end
