require_relative 'spec_helper'

RSpec.configure do |config|
  config.before :suite do
    SpecHelper.instance.provision('playbooks/nginx-playbook.yml',{
      domain: "dev-nfs.dev",
      http_root: "/srv/http-nfs"
    })
  end
end

describe command("nginx -t") do
  # stderr?? Wtf nginx.
  its(:stderr) { should match /configuration file \/etc\/nginx\/nginx\.conf syntax is ok/ }
  its(:stderr) { should match /configuration file \/etc\/nginx\/nginx\.conf test is successful/ }

  its(:exit_status) { should eq 0 }
end

describe command('printf "GET / HTTP/1.1\nHost: dev-nfs.dev\n\n" | nc 127.0.0.1 80') do
  # check headers
  its(:stdout) { should match /^+HTTP\/1\.1 200 OK$/ }

  # server directory listing
  its(:stdout) { should match /Index of \// }
end
