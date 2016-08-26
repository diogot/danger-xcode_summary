require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe Danger::DangerXcodeSummary do
    it 'should be a plugin' do
      expect(Danger::DangerXcodeSummary.new(nil)).to be_a Danger::Plugin
    end

    #
    # You should test your custom attributes and methods here
    #
    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @xcode_summary = @dangerfile.xcode_summary
        @xcode_summary.env.request_source.pr_json = {
          head: {
            repo: {
              html_url: 'https://github.com/diogot/danger-xcode_summary'
            },
            sha: '129jef029jf029fj2039fj203f92'
          }
        }
        @xcode_summary.project_root = '/Users/diogo/src/MyWeight/'
      end

      it 'fail if file does not exist' do
        @xcode_summary.report('spec/fixtures/inexistent_file.json')
        expect(@dangerfile.status_report[:errors]).to eq ['summary file not found']
      end

      describe 'summary' do
        it 'formats summary messages' do
          @xcode_summary.report('spec/fixtures/summary_messages.json')
          expect(@dangerfile.status_report[:messages]).to eq [
            'Executed 4 tests, with 0 failures (0 unexpected) in 0.012 (0.017) seconds'
          ]
        end

        it 'formats compile warnings' do
          @xcode_summary.report('spec/fixtures/summary.json')
          expect(@dangerfile.status_report[:warnings]).to eq [
            # rubocop:disable LineLength
            "**<a href='https://github.com/diogot/danger-xcode_summary/blob/129jef029jf029fj2039fj203f92/MyWeight/Bla.m#L32'>MyWeight/Bla.m#L32</a>**: Value stored to 'theme' is never read  <br />```\n            theme = *ptr++;\n```",
            "**<a href='https://github.com/diogot/danger-xcode_summary/blob/129jef029jf029fj2039fj203f92/MyWeight/Pods/ISO8601DateFormatter/ISO8601DateFormatter.m#L176'>MyWeight/Pods/ISO8601DateFormatter/ISO8601DateFormatter.m#L176</a>**: 'NSUndefinedDateComponent' is deprecated: first deprecated in iOS 8.0 - Use NSDateComponentUndefined instead [-Wdeprecated-declarations]  <br />```\n                month_or_week = NSUndefinedDateComponent,\n```"
            # rubocop:enable LineLength
          ]
        end

        it 'ignores file when ignored_files matches' do
          @xcode_summary.ignored_files = '**/Pods/**'
          @xcode_summary.report('spec/fixtures/summary.json')
          expect(@dangerfile.status_report[:warnings]).to eq [
            # rubocop:disable LineLength
            "**<a href='https://github.com/diogot/danger-xcode_summary/blob/129jef029jf029fj2039fj203f92/MyWeight/Bla.m#L32'>MyWeight/Bla.m#L32</a>**: Value stored to 'theme' is never read  <br />```\n            theme = *ptr++;\n```",
            # rubocop:enable LineLength
          ]
        end

        it 'ignores file when ignored_files is an array and matches' do
          @xcode_summary.ignored_files = ['**/Pods/**', '*.m']
          @xcode_summary.report('spec/fixtures/summary.json')
          expect(@dangerfile.status_report[:warnings]).to eq []
        end

        it 'formats test errors' do
          @xcode_summary.report('spec/fixtures/test_errors.json')
          expect(@dangerfile.status_report[:errors]).to eq [
            # rubocop:disable LineLength
            '**MyWeight.MyWeightSpec**: works_with_success, expected to eventually not be nil, got \<nil\>  <br />  ' \
            "<a href='https://github.com/diogot/danger-xcode_summary/blob/129jef029jf029fj2039fj203f92/MyWeight/MyWeightTests/Tests.swift#L86'>MyWeight/MyWeightTests/Tests.swift#L86</a>",
            # rubocop:enable LineLength
          ]
        end
      end
    end
  end
end
