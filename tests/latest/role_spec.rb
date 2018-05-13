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

  describe docker_image('traefik:latest') do
    it { should exist }
    its('repo') { should eq 'traefik'}
    its('tag') { should eq 'latest'}
  end
end

##
# latest
##
control "latest" do
  impact 0.7
  title "Test traefik with latest image"

  # container status
  describe docker_container('traefik') do
    it { should exist }
    it { should be_running }
    its('image') { should eq 'traefik:latest' }
    its('repo') { should eq 'traefik' }
    its('tag') { should eq 'latest' }
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
  # config values
  describe toml('/etc/traefik/traefik.toml') do
  end
end
