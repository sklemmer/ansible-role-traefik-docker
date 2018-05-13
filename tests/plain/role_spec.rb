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
end

##
# plain
##
control "plain" do
  impact 0.7
  title "Test traefik without any special config"

  # container status
  describe docker_container('traefik') do
    it { should exist }
    it { should be_running }
    its('image') { should eq 'traefik:alpine' }
    its('repo') { should eq 'traefik' }
    its('tag') { should eq 'alpine' }
    its('ports') { should eq "0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 0.0.0.0:8080->8080/tcp" }
  end
  # port existence
  ports = [ 80, 8080, 443]
  ports.each do |p|
    describe port("#{p}") do
      it { should be_listening }
      its('protocols') { should include 'tcp' }
    end
  end
  # config file existence
  describe file('/etc/traefik/traefik.toml') do
    it { should exist }
    its('type') { should eq :file }
  end
end
