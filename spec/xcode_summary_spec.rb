# frozen_string_literal: true

# rubocop:disable Layout/LineLength

require File.expand_path('spec_helper', __dir__)

module Danger
  describe Danger::DangerXcodeSummary do
    it 'should be a plugin' do
      expect(Danger::DangerXcodeSummary.new(nil)).to be_a Danger::Plugin
    end

    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @xcode_summary = @dangerfile.xcode_summary
        @xcode_summary.env.request_source.pr_json = JSON.parse(File.read('spec/fixtures/pr_json.json'))
        @xcode_summary.project_root = '/Users/marcelofabri/SwiftLint/'
      end

      it 'fail if file does not exist' do
        @xcode_summary.report('spec/fixtures/inexistent_file.xcresult')
        expect(@dangerfile.status_report[:errors]).to eq ['summary file not found']
      end

      describe 'summary' do
        context 'enabled' do
          it 'formats summary messages' do
            @xcode_summary.test_summary = true
            @xcode_summary.report('spec/fixtures/swiftlint.xcresult')
            expect(@dangerfile.status_report[:messages]).to eq [
              'SwiftLintFrameworkTests: Executed 540 tests, with 1 failures (0 expected) in 114.029 (27.922) seconds'
            ]
          end
        end

        context 'disabled' do
          it 'shows no summary messages' do
            @xcode_summary.test_summary = false
            @xcode_summary.report('spec/fixtures/swiftlint.xcresult')
            expect(@dangerfile.status_report[:messages]).to eq []
          end
        end
      end

      context 'reporting' do
        it 'formats compile warnings' do
          @xcode_summary.report('spec/fixtures/swiftlint.xcresult')
          expect(@dangerfile.status_report[:warnings]).to eq [
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Tag.swift#L88'>Carthage/Checkouts/Yams/Sources/Yams/Tag.swift#L88</a>**: Legacy Hashing Violation: Prefer using the `hash(into:)` function instead of overriding `hashValue` (legacy_hashing)",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Tag.swift#L109'>Carthage/Checkouts/Yams/Sources/Yams/Tag.swift#L109</a>**: Legacy Hashing Violation: Prefer using the `hash(into:)` function instead of overriding `hashValue` (legacy_hashing)",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Decoder.swift#L102'>Carthage/Checkouts/Yams/Sources/Yams/Decoder.swift#L102</a>**: Colon Violation: Colons should be next to the identifier when specifying a type and next to the key in dictionary literals. (colon)",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Node.swift#L191'>Carthage/Checkouts/Yams/Sources/Yams/Node.swift#L191</a>**: Legacy Hashing Violation: Prefer using the `hash(into:)` function instead of overriding `hashValue` (legacy_hashing)",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Representer.swift#L187'>Carthage/Checkouts/Yams/Sources/Yams/Representer.swift#L187</a>**: Todo Violation: TODOs should be resolved (Support `Float80`). (todo)",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Encoder.swift#L139'>Carthage/Checkouts/Yams/Sources/Yams/Encoder.swift#L139</a>**: Colon Violation: Colons should be next to the identifier when specifying a type and next to the key in dictionary literals. (colon)",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Parser.swift#L441'>Carthage/Checkouts/Yams/Sources/Yams/Parser.swift#L441</a>**: File Line Length Violation: File should contain 400 lines or less: currently contains 441 (file_length)",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Constructor.swift#L405'>Carthage/Checkouts/Yams/Sources/Yams/Constructor.swift#L405</a>**: Todo Violation: TODOs should be resolved (YAML supports keys other than ...). (todo)",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Constructor.swift#L430'>Carthage/Checkouts/Yams/Sources/Yams/Constructor.swift#L430</a>**: Todo Violation: TODOs should be resolved (Should raise error on other th...). (todo)",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Constructor.swift#L450'>Carthage/Checkouts/Yams/Sources/Yams/Constructor.swift#L450</a>**: Todo Violation: TODOs should be resolved (YAML supports Hashable element...). (todo)",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Constructor.swift#L478'>Carthage/Checkouts/Yams/Sources/Yams/Constructor.swift#L478</a>**: Todo Violation: TODOs should be resolved (Should raise error if subnode ...). (todo)",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Constructor.swift#L492'>Carthage/Checkouts/Yams/Sources/Yams/Constructor.swift#L492</a>**: Todo Violation: TODOs should be resolved (Should raise error if subnode ...). (todo)",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Emitter.swift#L340'>Carthage/Checkouts/Yams/Sources/Yams/Emitter.swift#L340</a>**: Todo Violation: TODOs should be resolved (Support tags). (todo)",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Tests/YamsTests/SpecTests.swift#L379'>Carthage/Checkouts/Yams/Tests/YamsTests/SpecTests.swift#L379</a>**: Todo Violation: TODOs should be resolved (YAML supports keys other than ...). (todo)",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Tests/YamsTests/SpecTests.swift#L714'>Carthage/Checkouts/Yams/Tests/YamsTests/SpecTests.swift#L714</a>**: Todo Violation: TODOs should be resolved (local tag parsing). (todo)",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Tests/YamsTests/EncoderTests.swift#L924'>Carthage/Checkouts/Yams/Tests/YamsTests/EncoderTests.swift#L924</a>**: Colon Violation: Colons should be next to the identifier when specifying a type and next to the key in dictionary literals. (colon)",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Tests/YamsTests/EncoderTests.swift#L937'>Carthage/Checkouts/Yams/Tests/YamsTests/EncoderTests.swift#L937</a>**: Colon Violation: Colons should be next to the identifier when specifying a type and next to the key in dictionary literals. (colon)",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Tests/YamsTests/EncoderTests.swift#L253'>Carthage/Checkouts/Yams/Tests/YamsTests/EncoderTests.swift#L253</a>**: Superfluous Disable Command Violation: 'unused_private_declaration' is not a valid SwiftLint rule. Please remove it from the disable command. (superfluous_disable_command)",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/SWXMLHash/Source/XMLIndexer+XMLIndexerDeserializable.swift#L538'>Carthage/Checkouts/SWXMLHash/Source/XMLIndexer+XMLIndexerDeserializable.swift#L538</a>**: 'public' modifier is redundant for instance method declared in a public extension",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/SWXMLHash/Source/XMLIndexer+XMLIndexerDeserializable.swift#L552'>Carthage/Checkouts/SWXMLHash/Source/XMLIndexer+XMLIndexerDeserializable.swift#L552</a>**: 'public' modifier is redundant for instance method declared in a public extension",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Result/Result/NoError.swift#L8'>Carthage/Checkouts/Result/Result/NoError.swift#L8</a>**: Will never be executed"
          ]
        end

        it 'ignores file when ignored_files matches' do
          @xcode_summary.ignored_files = 'Carthage/**/Yams/**'
          @xcode_summary.report('spec/fixtures/swiftlint.xcresult')
          expect(@dangerfile.status_report[:warnings]).to eq [
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/SWXMLHash/Source/XMLIndexer+XMLIndexerDeserializable.swift#L538'>Carthage/Checkouts/SWXMLHash/Source/XMLIndexer+XMLIndexerDeserializable.swift#L538</a>**: 'public' modifier is redundant for instance method declared in a public extension",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/SWXMLHash/Source/XMLIndexer+XMLIndexerDeserializable.swift#L552'>Carthage/Checkouts/SWXMLHash/Source/XMLIndexer+XMLIndexerDeserializable.swift#L552</a>**: 'public' modifier is redundant for instance method declared in a public extension",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Result/Result/NoError.swift#L8'>Carthage/Checkouts/Result/Result/NoError.swift#L8</a>**: Will never be executed"
          ]
        end

        it 'ignores file when ignored_files is an array and matches' do
          @xcode_summary.ignored_files = ['Carthage/**/Yams/**', 'Carthage/**/SWXMLHash/**']
          @xcode_summary.report('spec/fixtures/swiftlint.xcresult')
          expect(@dangerfile.status_report[:warnings]).to eq [
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Result/Result/NoError.swift#L8'>Carthage/Checkouts/Result/Result/NoError.swift#L8</a>**: Will never be executed"
          ]
        end

        it 'formats test errors' do
          @xcode_summary.report('spec/fixtures/swiftlint.xcresult')
          expect(@dangerfile.status_report[:errors]).to eq [
            "**SwiftLintFrameworkTests.ColonRuleTests.testColonWithoutApplyToDictionaries()**: XCTAssertEqual failed: (\"0\") is not equal to (\"1\")  <br />  <a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Tests/SwiftLintFrameworkTests/TestHelpers.swift#L169'>Tests/SwiftLintFrameworkTests/TestHelpers.swift#L169</a>"
          ]
        end

        it 'formats errors' do
          @xcode_summary.report('spec/fixtures/build_error.xcresult')
          expect(@dangerfile.status_report[:errors]).to eq [
            'Testing cancelled because the build failed.',
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Source/SwiftLintFramework/Extensions/QueuedPrint.swift#L13'>Source/SwiftLintFramework/Extensions/QueuedPrint.swift#L13</a>**: Use of unresolved identifier 'queue'",
            "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Source/SwiftLintFramework/Extensions/QueuedPrint.swift#L17'>Source/SwiftLintFramework/Extensions/QueuedPrint.swift#L17</a>**: Use of unresolved identifier 'queue'"
          ]
        end

        it 'report warning and error counts' do
          result = @xcode_summary.warning_error_count('spec/fixtures/build_error.xcresult')
          expect(result).to eq '{"warnings":21,"errors":3}'
        end

        context 'with inline_mode' do
          before do
            @xcode_summary.inline_mode = true
          end

          it 'asserts errors on the line' do
            allow(@xcode_summary).to receive(:fail)
            @xcode_summary.report('spec/fixtures/build_error.xcresult')
            expect(@xcode_summary).to have_received(:fail).with(
              instance_of(String),
              sticky: false,
              file: 'Source/SwiftLintFramework/Extensions/QueuedPrint.swift',
              line: 13
            )
            expect(@xcode_summary).to have_received(:fail).with(
              instance_of(String),
              sticky: false,
              file: 'Source/SwiftLintFramework/Extensions/QueuedPrint.swift',
              line: 17
            )
            expect(@xcode_summary).to have_received(:fail).with(
              'Testing cancelled because the build failed.',
              sticky: false
            )
          end

          it 'asserts warning on the line' do
            allow(@xcode_summary).to receive(:warn)
            @xcode_summary.report('spec/fixtures/swiftlint.xcresult')
            expect(@xcode_summary).to have_received(:warn).with(
              instance_of(String),
              sticky: false,
              file: 'Carthage/Checkouts/SWXMLHash/Source/XMLIndexer+XMLIndexerDeserializable.swift',
              line: 538
            )
          end
        end

        context 'with ignores_warnings' do
          before do
            @xcode_summary.ignores_warnings = true
          end

          it 'shows no warnings' do
            @xcode_summary.report('spec/fixtures/swiftlint.xcresult')
            expect(@dangerfile.status_report[:warnings]).to eq []
          end

          it 'shows errors' do
            @xcode_summary.report('spec/fixtures/build_error.xcresult')
            expect(@dangerfile.status_report[:warnings]).to eq []
            expect(@dangerfile.status_report[:errors].count).to_not eq 0
          end

          it 'reports warning and error counts with no warnings' do
            result = @xcode_summary.warning_error_count('spec/fixtures/build_error.xcresult')
            expect(result).to eq '{"warnings":0,"errors":3}'
          end
        end

        context 'with ignored_results' do
          before do
            @xcode_summary.ignored_results do |result|
              result.message.include?('public extension') || result.message.include?('unresolved')
            end
          end

          it 'asserts no errors' do
            @xcode_summary.report('spec/fixtures/build_error.xcresult')
            expect(@dangerfile.status_report[:errors].count).to eq 1
          end

          it 'asserts no warnings' do
            @xcode_summary.report('spec/fixtures/swiftlint.xcresult')
            expect(@dangerfile.status_report[:warnings].count).to eq 19
          end

          it 'report warning and error counts' do
            result = @xcode_summary.warning_error_count('spec/fixtures/build_error.xcresult')
            expect(result).to eq '{"warnings":19,"errors":1}'
          end
        end

        context 'without strict' do
          before do
            @xcode_summary.strict = false
          end

          it 'shows errors as warnings' do
            @xcode_summary.report('spec/fixtures/build_error.xcresult')
            expect(@dangerfile.status_report[:warnings].count).to_not eq 0
            expect(@dangerfile.status_report[:errors]).to eq []
          end

          it 'report warning and error counts' do
            result = @xcode_summary.warning_error_count('spec/fixtures/build_error.xcresult')
            expect(result).to eq '{"warnings":21,"errors":3}'
          end
        end

        context 'with sort_warnings_by' do
          before do
            @xcode_summary.sort_warnings_by do |warning|
              warning.message.include?('TODOs') ? 0 : 1
            end
          end
          it 'sorts compile warnings' do
            @xcode_summary.report('spec/fixtures/swiftlint.xcresult')
            expect(@dangerfile.status_report[:warnings]).to eq [
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Constructor.swift#L492'>Carthage/Checkouts/Yams/Sources/Yams/Constructor.swift#L492</a>**: Todo Violation: TODOs should be resolved (Should raise error if subnode ...). (todo)",
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Tests/YamsTests/SpecTests.swift#L379'>Carthage/Checkouts/Yams/Tests/YamsTests/SpecTests.swift#L379</a>**: Todo Violation: TODOs should be resolved (YAML supports keys other than ...). (todo)",
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Tests/YamsTests/SpecTests.swift#L714'>Carthage/Checkouts/Yams/Tests/YamsTests/SpecTests.swift#L714</a>**: Todo Violation: TODOs should be resolved (local tag parsing). (todo)",
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Representer.swift#L187'>Carthage/Checkouts/Yams/Sources/Yams/Representer.swift#L187</a>**: Todo Violation: TODOs should be resolved (Support `Float80`). (todo)",
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Constructor.swift#L405'>Carthage/Checkouts/Yams/Sources/Yams/Constructor.swift#L405</a>**: Todo Violation: TODOs should be resolved (YAML supports keys other than ...). (todo)",
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Constructor.swift#L430'>Carthage/Checkouts/Yams/Sources/Yams/Constructor.swift#L430</a>**: Todo Violation: TODOs should be resolved (Should raise error on other th...). (todo)",
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Constructor.swift#L450'>Carthage/Checkouts/Yams/Sources/Yams/Constructor.swift#L450</a>**: Todo Violation: TODOs should be resolved (YAML supports Hashable element...). (todo)",
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Constructor.swift#L478'>Carthage/Checkouts/Yams/Sources/Yams/Constructor.swift#L478</a>**: Todo Violation: TODOs should be resolved (Should raise error if subnode ...). (todo)",
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Emitter.swift#L340'>Carthage/Checkouts/Yams/Sources/Yams/Emitter.swift#L340</a>**: Todo Violation: TODOs should be resolved (Support tags). (todo)",
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/SWXMLHash/Source/XMLIndexer+XMLIndexerDeserializable.swift#L538'>Carthage/Checkouts/SWXMLHash/Source/XMLIndexer+XMLIndexerDeserializable.swift#L538</a>**: 'public' modifier is redundant for instance method declared in a public extension",
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/SWXMLHash/Source/XMLIndexer+XMLIndexerDeserializable.swift#L552'>Carthage/Checkouts/SWXMLHash/Source/XMLIndexer+XMLIndexerDeserializable.swift#L552</a>**: 'public' modifier is redundant for instance method declared in a public extension",
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Tag.swift#L88'>Carthage/Checkouts/Yams/Sources/Yams/Tag.swift#L88</a>**: Legacy Hashing Violation: Prefer using the `hash(into:)` function instead of overriding `hashValue` (legacy_hashing)",
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Result/Result/NoError.swift#L8'>Carthage/Checkouts/Result/Result/NoError.swift#L8</a>**: Will never be executed",
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Tag.swift#L109'>Carthage/Checkouts/Yams/Sources/Yams/Tag.swift#L109</a>**: Legacy Hashing Violation: Prefer using the `hash(into:)` function instead of overriding `hashValue` (legacy_hashing)",
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Decoder.swift#L102'>Carthage/Checkouts/Yams/Sources/Yams/Decoder.swift#L102</a>**: Colon Violation: Colons should be next to the identifier when specifying a type and next to the key in dictionary literals. (colon)",
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Node.swift#L191'>Carthage/Checkouts/Yams/Sources/Yams/Node.swift#L191</a>**: Legacy Hashing Violation: Prefer using the `hash(into:)` function instead of overriding `hashValue` (legacy_hashing)",
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Encoder.swift#L139'>Carthage/Checkouts/Yams/Sources/Yams/Encoder.swift#L139</a>**: Colon Violation: Colons should be next to the identifier when specifying a type and next to the key in dictionary literals. (colon)",
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Sources/Yams/Parser.swift#L441'>Carthage/Checkouts/Yams/Sources/Yams/Parser.swift#L441</a>**: File Line Length Violation: File should contain 400 lines or less: currently contains 441 (file_length)",
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Tests/YamsTests/EncoderTests.swift#L924'>Carthage/Checkouts/Yams/Tests/YamsTests/EncoderTests.swift#L924</a>**: Colon Violation: Colons should be next to the identifier when specifying a type and next to the key in dictionary literals. (colon)",
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Tests/YamsTests/EncoderTests.swift#L937'>Carthage/Checkouts/Yams/Tests/YamsTests/EncoderTests.swift#L937</a>**: Colon Violation: Colons should be next to the identifier when specifying a type and next to the key in dictionary literals. (colon)",
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Carthage/Checkouts/Yams/Tests/YamsTests/EncoderTests.swift#L253'>Carthage/Checkouts/Yams/Tests/YamsTests/EncoderTests.swift#L253</a>**: Superfluous Disable Command Violation: 'unused_private_declaration' is not a valid SwiftLint rule. Please remove it from the disable command. (superfluous_disable_command)"
            ]
          end

          it 'formats errors' do
            @xcode_summary.report('spec/fixtures/build_error.xcresult')
            expect(@dangerfile.status_report[:errors]).to eq [
              'Testing cancelled because the build failed.',
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Source/SwiftLintFramework/Extensions/QueuedPrint.swift#L13'>Source/SwiftLintFramework/Extensions/QueuedPrint.swift#L13</a>**: Use of unresolved identifier 'queue'",
              "**<a href='https://github.com/realm/SwiftLint/blob/f211694e7def13785ff62047386437534541d7b3/Source/SwiftLintFramework/Extensions/QueuedPrint.swift#L17'>Source/SwiftLintFramework/Extensions/QueuedPrint.swift#L17</a>**: Use of unresolved identifier 'queue'"
            ]
          end

          it 'report warning and error counts' do
            result = @xcode_summary.warning_error_count('spec/fixtures/build_error.xcresult')
            expect(result).to eq '{"warnings":21,"errors":3}'
          end
        end

        context 'with collapse_parallelized_tests' do
          context 'enabled' do
            before do
              @xcode_summary.collapse_parallelized_tests = true
            end

            it 'collapses test runs from the same target' do
              # Allow for message receiving testing
              allow(@xcode_summary).to receive(:message).and_call_original
              @xcode_summary.report('spec/fixtures/swiftlint.xcresult')

              # Ensure that the plugin received a call to message with the combined test results
              expect(@xcode_summary).to have_received(:message).with(/SwiftLintFrameworkTests: Executed .* tests/m, sticky: false)

              # The standard test case should only show one message per target, even with parallelized tests
              expect(@dangerfile.status_report[:messages].length).to eq(1)
            end
          end

          context 'disabled' do
            before do
              @xcode_summary.collapse_parallelized_tests = false
            end

            it 'shows individual test runs for each target' do
              @xcode_summary.report('spec/fixtures/swiftlint.xcresult')

              # We know from the existing tests that the standard behavior should match
              # the test in the "summary" context, with one test run per message
              expect(@dangerfile.status_report[:messages]).to eq [
                'SwiftLintFrameworkTests: Executed 540 tests, with 1 failures (0 expected) in 114.029 (27.922) seconds'
              ]
            end
          end

          context 'with default value' do
            it 'defaults to disabled behavior' do
              # Don't set collapse_parallelized_tests to test the default
              # Reset any test_summary setting to ensure clean state
              @xcode_summary.test_summary = true

              @xcode_summary.report('spec/fixtures/swiftlint.xcresult')

              # Default should match the disabled behavior
              expect(@dangerfile.status_report[:messages]).to eq [
                'SwiftLintFrameworkTests: Executed 540 tests, with 1 failures (0 expected) in 114.029 (27.922) seconds'
              ]

              # Verify the default value is false
              expect(@xcode_summary.collapse_parallelized_tests).to eq(false)
            end
          end
        end
      end
    end

    # Test retried tests functionality
    describe 'with retried tests' do
      before do
        @dangerfile = testing_dangerfile
        @xcode_summary = @dangerfile.xcode_summary
        @xcode_summary.env.request_source.pr_json = JSON.parse(File.read('spec/fixtures/pr_json.json'))
        @xcode_summary.project_root = '/Users/marcelofabri/SwiftLint/'
      end

      context 'with ignore_retried_tests enabled' do
        before do
          @xcode_summary.ignore_retried_tests = true
        end

        it 'ignores test failures that succeeded on retry' do
          @xcode_summary.report('spec/fixtures/retried_tests.xcresult')
          # The retried test should not show up as an error since it ultimately succeeded
          expect(@dangerfile.status_report[:errors]).to eq []
        end

        it 'shows test summary with retry information' do
          @xcode_summary.test_summary = true
          @xcode_summary.report('spec/fixtures/retried_tests.xcresult')
          # The test summary should still show execution information
          expect(@dangerfile.status_report[:messages].length).to eq 1
          expect(@dangerfile.status_report[:messages].first).to match('retried-testTests: Executed 2 tests, with 0 failures (0 expected) in 0.158 (0.158) seconds')
        end

        it 'shows no error count' do
          result = @xcode_summary.warning_error_count('spec/fixtures/retried_tests.xcresult')
          expect(result).to eq '{"warnings":0,"errors":0}'
        end

        it 'defaults to false' do
          # Create a fresh instance to test default value
          fresh_dangerfile = testing_dangerfile
          fresh_xcode_summary = fresh_dangerfile.xcode_summary
          expect(fresh_xcode_summary.ignore_retried_tests).to eq false
        end
      end

      context 'with ignore_retried_tests disabled' do
        before do
          @xcode_summary.ignore_retried_tests = false
        end

        it 'still reports test failures even if they succeeded on retry' do
          @xcode_summary.report('spec/fixtures/retried_tests.xcresult')
          # With retry filtering disabled, failed tests should still be reported
          expect(@dangerfile.status_report[:errors].length).to eq 1
        end

        it 'count retry as error' do
          result = @xcode_summary.warning_error_count('spec/fixtures/retried_tests.xcresult')
          expect(result).to eq '{"warnings":0,"errors":1}'
        end
      end
    end

    # Second environment with different request_source
    describe 'with bitbucket request_source' do
      before do
        @dangerfile = testing_bitbucket_dangerfile
        @xcode_summary = @dangerfile.xcode_summary
        @xcode_summary.env.request_source.pr_json = JSON.parse(File.read('spec/fixtures/bitbucket_pr.json'), symbolize_names: true)
        @xcode_summary.project_root = '/Users/diogo/src/danger-xcode_summary'
      end

      describe 'where request source' do
        it 'should be bitbucket' do
          path = @xcode_summary.send(:format_path, 'lib/xcode_summary/plugin.rb', 3)
          expect(path).to eq 'lib/xcode_summary/plugin.rb'
        end
      end
    end
  end
end
# rubocop:enable Layout/LineLength
