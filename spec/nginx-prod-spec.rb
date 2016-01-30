require_relative 'spec_helper'

RSpec.configure do |config|
  config.before :suite do
    SpecHelper.instance.provision('playbooks/nginx-playbook.yml', { app_env: "production" })
  end
end

describe command("nginx -t") do
  # stderr?? Wtf nginx.
  its(:stderr) { should match /configuration file \/etc\/nginx\/nginx\.conf syntax is ok/ }
  its(:stderr) { should match /configuration file \/etc\/nginx\/nginx\.conf test is successful/ }

  its(:exit_status) { should eq 0 }
end

describe file("/etc/nginx/nginx.conf") do
  its(:content) { should match /^\s+sendfile\s+on;$/ }
end
