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
        @xcode_summary.env.request_source.pr_json = JSON.parse(IO.read('spec/fixtures/pr_json.json'))
        @xcode_summary.project_root = '/Users/diogo/src/MyWeight'
      end

      it 'sets sticky_summary to false as default' do
        expect(@xcode_summary.sticky_summary).to eq false
      end

      it 'sets test_summary to true as default' do
        expect(@xcode_summary.test_summary).to eq true
      end

      it 'fail if file does not exist' do
        @xcode_summary.report('spec/fixtures/inexistent_file.json')
        expect(@dangerfile.status_report[:errors]).to eq ['summary file not found']
      end

      describe 'summary' do
        context 'enabled' do
          it 'formats summary messages' do
            @xcode_summary.test_summary = true
            @xcode_summary.report('spec/fixtures/summary_messages.json')
            expect(@dangerfile.status_report[:messages]).to eq [
              'Executed 4 tests, with 0 failures (0 unexpected) in 0.012 (0.017) seconds'
            ]
          end
        end

        context 'disabled' do
          it 'shows no summary messages' do
            @xcode_summary.test_summary = false
            @xcode_summary.report('spec/fixtures/summary_messages.json')
            expect(@dangerfile.status_report[:messages]).to eq []
          end
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

        it 'formats compile warnings with empty line' do
          @xcode_summary.report('spec/fixtures/summary_with_empty_line.json')
          expect(@dangerfile.status_report[:warnings]).to eq [
            # rubocop:disable LineLength
            "**<a href='https://github.com/diogot/danger-xcode_summary/blob/129jef029jf029fj2039fj203f92/Users/marcelofabri/Developer/MyAwesomeProject/MyAwesomeProject/Classes/AppDelegate.swift#L10001'>/Users/marcelofabri/Developer/MyAwesomeProject/MyAwesomeProject/Classes/AppDelegate.swift#L10001</a>**: File should contain 400 lines or less: currently contains 10001  <br />"
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

        it 'formats errors' do
          @xcode_summary.report('spec/fixtures/errors.json')
          expect(@dangerfile.status_report[:errors]).to eq [
            'some error',
            'another error'
          ]
        end

        context 'with inline_mode' do
          before do
            @xcode_summary.inline_mode = true
          end

          it 'asserts errors on the line' do
            allow(@xcode_summary).to receive(:fail)
            @xcode_summary.report('spec/fixtures/test_errors.json')
            expect(@xcode_summary).to have_received(:fail).with(
              instance_of(String),
              sticky: false,
              file: 'MyWeight/MyWeightTests/Tests.swift',
              line: 86
            )
          end

          it 'asserts warning on the line' do
            allow(@xcode_summary).to receive(:warn)
            @xcode_summary.report('spec/fixtures/summary.json')
            expect(@xcode_summary).to have_received(:warn).with(
              instance_of(String),
              sticky: false,
              file: 'Bla.m',
              line: 32
            )
            expect(@xcode_summary).to have_received(:warn).with(
              instance_of(String),
              sticky: false,
              file: 'ISO8601DateFormatter.m',
              line: 176
            )
          end
        end

        context 'with ignored_categories' do
          before { @xcode_summary.ignored_categories = %i[errors ld_warnings] }

          it 'asserts no errors' do
            @xcode_summary.report('spec/fixtures/errors.json')
            expect(@dangerfile.status_report[:errors]).to be_empty
          end

          it 'asserts no warnings' do
            @xcode_summary.report('spec/fixtures/ld_warnings.json')
            expect(@dangerfile.status_report[:warnings]).to be_empty
          end
        end
      end
    end

    # Second environment with different request_source
    describe 'with bitbucket request_source' do
      before do
        @dangerfile = testing_bitbucket_dangerfile
        @xcode_summary = @dangerfile.xcode_summary
        # rubocop:disable LineLength
        @xcode_summary.env.request_source.pr_json = JSON.parse(IO.read('spec/fixtures/bitbucket_pr.json'), symbolize_names: true)
        # rubocop:enable LineLength
        @xcode_summary.project_root = '/Users/diogo/src/danger-xcode_summary'
      end

      describe 'where request source' do
        it 'should be bitbucket' do
          path = @xcode_summary.send(:format_path, 'lib/xcode_summary/plugin.rb#L3')
          # rubocop:disable LineLength
          expect(path).to eq "<a href='https://github.com/diogot/danger-xcode_summary/lib/xcode_summary/plugin.rb?at=4d4c0f31857e3185b51b6865a0700525bc0cb2bb#L3'>lib/xcode_summary/plugin.rb</a>"
          # rubocop:enable LineLength
        end
      end
    end
  end
end
