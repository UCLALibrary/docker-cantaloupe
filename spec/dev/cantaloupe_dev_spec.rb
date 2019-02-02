require 'dockerspec/serverspec'
require 'dockerspec/infrataster'

docker_opts = {'build-arg' => 'CANTALOUPE_VERSION=latest'}

### test cantaloupe_dev (i.e. the bleeding-edge/develop build)
describe docker_build('.', tag: 'uclalibrary/cantaloupe_dev', opts: docker_opts) do

  it { should have_expose '8182' }

  describe docker_build('spec/dev/', tag: 'uclalibrary/cantaloupe_dev_test') do
    docker_env = {  'CANTALOUPE_VERSION' => 'latest',
                    'ENDPOINT_ADMIN_SECRET' => 'secret',
                    'ENDPOINT_ADMIN_ENABLED' => 'true' }
    wait = ENV['TRAVIS'] ? 10 : 2

    describe docker_run('uclalibrary/cantaloupe_dev_test', env: docker_env, wait: wait) do
      ### refactor, what packages? does it even matter?
      # describe package('nodejs') do
      #   it { should be_installed }
      # end
      ### refactor, what commands make sense to run?
      # it 'has node in the path' do
      #   expect(command('which node || which nodejs').exit_status).to eq 0
      # end
      ### refactor, what processes should be running?
      # describe process('su -m -l dradis -c exec bundle exec rails server') do
      #   it { should be_running }
      # end

      describe port('8182') do
        it { should be_listening }
      end

      describe server(described_container) do
        describe http('http://localhost:8182/') do
          it 'contains "Cantaloupe Image Server"' do
            expect(response.body).to match(/Cantaloupe Image Server/)
          end

          it 'does not contain "Oops"' do
            expect(response.body).to_not match(/Oops/i)
          end

          it 'contains the expected version number, 4.1.0' do
            expect(response.body).to match(/Cantaloupe Image Server \<small\>4.1.0\<\/small\>/)
          end
        end
        describe file('/etc/cantaloupe.properties') do
          it { should be_file }
          it { should be_mode 644 }
          it { should be_owned_by 'cantaloupe'}
          it { should be_grouped_into 'root' }
        end
      end
    end
  end
end
