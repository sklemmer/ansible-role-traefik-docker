# spec/features/external_request_spec.rb

##
# general
##
control "general" do
  impact 0.7
  title "Test General Docker Config"

  describe service('docker') do
    it {should be_installed}
    it {should be_enabled}
    it {should be_running}
  end

  describe docker_image('traefik:alpine') do
    it { should exist }
    its('repo') { should eq 'traefik'}
    its('tag') { should eq 'alpine'}
  end

  # container status
  describe docker_container('traefik') do
    it { should exist }
    it { should be_running }
    its('image') { should eq 'traefik:alpine' }
    its('repo') { should eq 'traefik' }
    its('tag') { should eq 'alpine' }
    its('ports') { should eq "0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 0.0.0.0:8080->8080/tcp" }
  end
  # config file existence
  describe file('/etc/traefik/traefik.toml') do
    it { should exist }
    its('type') { should eq :file }
  end
end

control "reachabiity" do
  impact 0.7
  title "Test traefik reachability"

  # port existence
  ports = [ 80, 8080, 443]
  ports.each do |p|
    describe port("#{p}") do
      it { should be_listening }
      its('protocols') { should include 'tcp' }
    end
  end
  # http requests
  describe http('http://localhost:80') do
    its('status') { should cmp 404 }
  end
  describe http('http://localhost:8080/dashboard/') do
    its('status') { should cmp 200 }
  end
end

##
# enable ping
##
control "ping" do
  impact 0.7
  title "Test traefik with ping"

  # config values
  describe toml('/etc/traefik/traefik.toml') do
    its(['ping', 'entrypoint']) { should eq 'traefik' }
  end
  
  describe http('http://localhost:8080/ping') do
    its('status') { should cmp 200 }
    its('body') { should cmp 'OK' }
    its('headers.Content-Type') { should cmp 'text/plain; charset=utf-8' }
  end
end
