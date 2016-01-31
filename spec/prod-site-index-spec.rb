require_relative "lib/ansible_helper"
require_relative "bootstrap"

RSpec.configure do |config|
  config.before :suite do
    AnsibleHelper.instance.playbook("playbooks/nginx-playbook.yml", {
      domain:     "prod-index.dev",
      copy_index: true,
      env_name:   "prod"
    })
  end
end

describe command("nginx -t") do
  # stderr?? Wtf nginx.
  its(:stderr) { should match /configuration file \/etc\/nginx\/nginx\.conf syntax is ok/ }
  its(:stderr) { should match /configuration file \/etc\/nginx\/nginx\.conf test is successful/ }

  its(:exit_status) { should eq 0 }
end

describe command('printf "GET / HTTP/1.1\nHost: prod-index.dev\n\n" | nc 127.0.0.1 80') do
  # check headers
  its(:stdout) { should match /^+HTTP\/1\.1 200 OK$/ }

  its(:stdout) { should match /Nginx is serving content on prod-index\.dev/ }

  describe command("tail -n 1 /var/log/nginx/prod-index.dev/static.log") do
    its(:stdout) { should match /^127\.0\.0\.1 - - \[[ 0-9a-zA-Z\/:+]+\] "GET \/ HTTP\/1\.1" 200 \d+ "-" "-"$/ }
  end
end
