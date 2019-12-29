require "docker_helper"

### DOCKER_CONTAINER ###########################################################

describe "Docker container", :test => :docker_container do
  # Default Serverspec backend
  before(:each) { set :backend, :docker }

  ### DOCKER_CONTAINER #########################################################

  describe docker_container(ENV["CONTAINER_NAME"]) do
    # Execute Serverspec command locally
    before(:each) { set :backend, :exec }
    it { is_expected.to be_running }
  end

  ### PROCESSES ################################################################

  describe "Processes" do
    # [process, user, group, pid]
    processes = [
      ["/sbin/tini", 1000, 2000, 1],
    ]

    processes.each do |process, user, group, pid|
      context process(process) do
        it { is_expected.to be_running }
        its(:pid) { is_expected.to eq(pid) } unless pid.nil?
        its(:user) { is_expected.to eq(user) } unless user.nil?
        its(:group) { is_expected.to eq(group) } unless group.nil?
      end
    end
  end

  ### DOCKER_ENTRYPOINT ########################################################

  describe "Docker Entrypoint", :test => :entrypoint do

    # TODO: /service/entrypoint.d
    # TODO: /entrypoint.d/20.default-command.sh

    wait_for_script = "/entrypoint/90.wait-for.sh"

    ### /entrypoint.d/90-wait-for.sh ###########################################

    describe wait_for_script do
      context "#wait_for_dns" do
        # [url,                                   exit_status, match]
        [
          ["service",                             0, "Got the 'service' address \\d+\\.\\d+\\.\\d+\\.\\d+ in \\d+s"],
          ["service:8080",                        0, "Got the 'service' address \\d+\\.\\d+\\.\\d+\\.\\d+ in \\d+s"],
          ["tcp://service:8080",                  0, "Got the 'service' address \\d+\\.\\d+\\.\\d+\\.\\d+ in \\d+s"],
          ["http://service:8080/test",            0, "Got the 'service' address \\d+\\.\\d+\\.\\d+\\.\\d+ in \\d+s"],
          ["https://nonexistent:8888/test",       1, "'nonexistent' name resolution timed out after \\d+s"],
        ].each do |url, exit_status, match|
          context "resolve \"#{url}\"" do
            let!(:script) {
              <<-END
                error() {
                  echo "$*"
                }
                info()  {
                  echo "$*"
                }
                debug() {
                  echo "$*"
                }
                WAIT_FOR_TIMEOUT=1
                WAIT_FOR_DNS="#{url}"
                . #{wait_for_script}
              END
            }
            subject { command("/bin/bash -c '#{script}'") }
            its(:exit_status) { is_expected.to eq(exit_status) }
            its(:stdout) { is_expected.to match(/#{match}/) }
          end
        end
      end

      context "#wait_for_tcp" do
        # [url,                                   exit_status, match]
        [
          ["service:8080",                        0, "Got the connection to tcp://service:8080 in \\d+s"],
          ["http://service:8080/test",            0, "Got the connection to tcp://service:8080 in \\d+s"],
          ["imaps://imap.gmail.com",              0, "Got the connection to tcp://imap.gmail.com:993 in \\d+s"],
          ["http://service/test",                 1, "Connection to tcp://service:80 timed out after \\d+s"],
          ["https://nonexistent:8888/test",       1, "'nonexistent' name resolution timed out after \\d+s"],
        ].each do |url, exit_status, match|
          context "connect to \"#{url}\"" do
            let!(:script) {
              <<-END
                error() {
                  echo "$*"
                }
                info()  {
                  echo "$*"
                }
                debug() {
                  echo "$*"
                }
                WAIT_FOR_TIMEOUT=1
                WAIT_FOR_TCP="#{url}"
                . #{wait_for_script}
              END
            }
            subject { command("/bin/bash -c '#{script}'") }
            its(:exit_status) { is_expected.to eq(exit_status) }
            its(:stdout) { is_expected.to match(/#{match}/) }
          end
        end
      end

      context "#wait_for_url" do
        # [url,                                   exit_status, match]
        [
          ["http://service:8080/test",            0, "Got the connection to http://service:8080/test in \\d+s"],
          ["imaps://imap.gmail.com",              0, "Got the connection to imaps://imap.gmail.com in \\d+s"],
          ["smtp://smtp.gmail.com",               0, "Got the connection to smtp://smtp.gmail.com in \\d+s"],
          ["http://service/test",                 1, "Connection to http://service/test timed out after \\d+s"],
          ["https://nonexistent:8888/test",       1, "'nonexistent' name resolution timed out after \\d+s"],
        ].each do |url, exit_status, match|
          context "connect to \"#{url}\"" do
            let!(:script) {
              <<-END
                error() {
                  echo "$*"
                }
                info()  {
                  echo "$*"
                }
                debug() {
                  echo "$*"
                }
                WAIT_FOR_TIMEOUT=1
                WAIT_FOR_URL="#{url}"
                . #{wait_for_script}
              END
            }
            subject { command("/bin/bash -c '#{script}'") }
            its(:exit_status) { is_expected.to eq(exit_status) }
            its(:stdout) { is_expected.to match(/#{match}/) }
          end
        end
      end
    end

  end

  ##############################################################################

end

################################################################################
