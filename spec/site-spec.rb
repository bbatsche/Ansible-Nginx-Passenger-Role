require_relative 'spec_helper'

RSpec.configure do |config|
  config.before :suite do
    SpecHelper.instance.provision 'playbooks/nginx-playbook.yml', domain: "test.dev"
  end
end

describe command("nginx -t") do
  # stderr?? Wtf nginx.
  its(:stderr) { should match /configuration file \/etc\/nginx\/nginx\.conf syntax is ok/ }
  its(:stderr) { should match /configuration file \/etc\/nginx\/nginx\.conf test is successful/ }

  its(:exit_status) { should eq 0 }
end

describe command('printf "GET / HTTP/1.1\nHost: test.dev\n\n" | nc 127.0.0.1 80') do
  # check headers
  its(:stdout) { should match /^+HTTP\/1\.1 200 OK$/ }
  its(:stdout) { should match /^X-UA-Compatible: IE=Edge$/ }
  its(:stdout) { should match /^X-Frame-Options: SAMEORIGIN$/ }
  its(:stdout) { should match /^X-Content-Type-Options: nosniff$/ }
  its(:stdout) { should match /^X-XSS-Protection: 1; mode=block$/ }
  its(:stdout) { should match /^Cache-Control: no-transform$/ }

  # server directory listing
  its(:stdout) { should match /Index of \// }
end
