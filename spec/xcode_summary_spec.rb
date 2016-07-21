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
        @summary = @xcode_summary.read_summary('spec/fixtures/summary.json')
      end

      it 'fail if file don\'t exists' do
        result = @xcode_summary.read_summary('spec/fixtures/inexistent_file.json')
        # expected = [Danger::Violation.new('summary file not found', true)]
        expect(result).to be_a Array
        expect(result.count).to eq(1)
        violation = result.first
        expect(violation).to be_a Danger::Violation
        expect(violation.message).to eq('summary file not found')
        expect(violation.sticky).to be_truthy
      end

      it 'reads a json summary' do
        expect(@summary.count).to eq 10
      end
      
      it 'contains warnings' do
          diagnostic = @summary[:warnings]
          expect(diagnostic.count).to eq 0
      end

      it 'contains ld_warnings' do
        diagnostic = @summary[:ld_warnings]
        expect(diagnostic.count).to eq 0
      end

      it 'contains compile_warnings' do
        diagnostic = @summary[:compile_warnings]
        expect(diagnostic.count).to eq 1
      end

      it 'contains errors' do
        diagnostic = @summary[:errors]
        expect(diagnostic.count).to eq 0
      end

      it 'contains compile_errors' do
        diagnostic = @summary[:compile_errors]
        expect(diagnostic.count).to eq 0
      end

      it 'contains file_missing_errors' do
        diagnostic = @summary[:file_missing_errors]
        expect(diagnostic.count).to eq 0
      end

      it 'contains undefined_symbols_errors' do
        diagnostic = @summary[:undefined_symbols_errors]
        expect(diagnostic.count).to eq 0
      end

      it 'contains duplicate_symbols_errors' do
        diagnostic = @summary[:duplicate_symbols_errors]
        expect(diagnostic.count).to eq 0
      end

      it 'contains tests_failures' do
        diagnostic = @summary[:tests_failures]
        expect(diagnostic.count).to eq 0
      end

      it 'contains tests_summary_messages' do
        diagnostic = @summary[:tests_summary_messages]
        expect(diagnostic.count).to eq 1
        expect(diagnostic.first).to eq "\t Executed 4 tests, with 0 failures (0 unexpected) in 0.012 (0.017) seconds\n"
      end

      it 'format summary' do
        @xcode_summary.format_summary(@summary)
      end

    end
  end
end

