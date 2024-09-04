# frozen_string_literal: true

require 'pathname'
ROOT = Pathname.new(File.expand_path('..', __dir__))
$LOAD_PATH.unshift("#{ROOT}lib".to_s)
$LOAD_PATH.unshift("#{ROOT}spec".to_s)

require 'bundler/setup'
require 'pry'

require 'rspec'
require 'danger'

require 'danger_plugin'

# Use coloured output, it's the best.
RSpec.configure do |config|
  config.filter_gems_from_backtrace 'bundler'
  config.color = true
  config.tty = true
  config.expect_with :rspec do |c|
    c.max_formatted_output_length = nil # n is number of lines, or nil for no truncation.
  end
end

# These functions are a subset of https://github.com/danger/danger/blob/master/spec/spec_helper.rb
# If you are expanding these files, see if it's already been done ^.

# A silent version of the user interface,
# it comes with an extra function `.string` which will
# strip all ANSI colours from the string.

def testing_ui
  @output = StringIO.new
  def @output.winsize
    [20, 9999]
  end

  cork = Cork::Board.new(out: @output)
  def cork.string
    out.string.gsub(/\e\[([;\d]+)?m/, '')
  end
  cork
end

# Example environment (ENV) that would come from
# running a PR on TravisCI
def testing_env
  {
    'HAS_JOSH_K_SEAL_OF_APPROVAL' => 'true',
    'TRAVIS_PULL_REQUEST' => '800',
    'TRAVIS_REPO_SLUG' => 'artsy/eigen',
    'TRAVIS_COMMIT_RANGE' => '759adcbd0d8f...13c4dc8bb61d',
    'DANGER_GITHUB_API_TOKEN' => '123sbdq54erfsd3422gdfio'
  }
end

def testing_bitbucket_env
  {
    'GIT_URL' => 'https://github.com/diogot/danger-xcode_summary.git',
    'CHANGE_ID' => '4d4c0f31857e3185b51b6865a0700525bc0cb2bb',
    'JENKINS_URL' => 'http://jenkins.server.com/',
    'DANGER_BITBUCKETCLOUD_USERNAME' => 'username',
    'DANGER_BITBUCKETCLOUD_PASSWORD' => 'password',
    'DANGER_BITBUCKETCLOUD_UUID' => 'c91be865-efc6-49a6-93c5-24e1267c479b',
    'ghprbPullId' => '2080'
  }
end

# A stubbed out Dangerfile for use in tests
def testing_dangerfile
  env = Danger::EnvironmentManager.new(testing_env)
  Danger::Dangerfile.new(env, testing_ui)
end

# A stubbed out Dangerfile with Bitbucket as a request_source for use in tests
def testing_bitbucket_dangerfile
  env = Danger::EnvironmentManager.new(testing_bitbucket_env)
  Danger::Dangerfile.new(env, testing_ui)
end
