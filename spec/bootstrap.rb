require "serverspec"
require_relative "lib/ansible_helper"

options = AnsibleHelper.instance.sshOptions

set :backend, :ssh

set :host,        options[:host_name]
set :ssh_options, options

# Disable sudo
set :disable_sudo, false

# Set environment variables
# set :env, :LANG => 'C', :LC_MESSAGES => 'C'

# Set PATH
set :path, '/sbin:/usr/local/sbin:/usr/local/bin:$PATH'

shared_examples "nginx::config" do
  describe command("nginx -t") do
    let(:disable_sudo) { false }

    it "has no errors" do
      expect(subject.stderr).to match /configuration file \/etc\/nginx\/nginx\.conf syntax is ok/
      expect(subject.stderr).to match /configuration file \/etc\/nginx\/nginx\.conf test is successful/

      expect(subject.exit_status).to eq 0
    end
  end
end
