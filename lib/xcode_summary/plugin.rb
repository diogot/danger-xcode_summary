# frozen_string_literal: true

require 'json'
require 'xcresult'

module Danger
  # Shows all build errors, warnings and unit tests results generated from `xcodebuild`.
  # You need to use the `xcresult` produced by Xcode 11. It's located in the Derived Data folder.
  # @example Showing summary
  #
  #          xcode_summary.report 'build.xcresult'
  #
  # @example Filtering warnings in Pods
  #
  #          xcode_summary.ignored_files = '**/Pods/**'
  #          xcode_summary.report 'build.xcresult'
  #
  # @see  diogot/danger-xcode_summary
  # @tags xcode, xcodebuild, format
  #
  class DangerXcodeSummary < Plugin
    Location = Struct.new(:file_name, :file_path, :line)
    Result = Struct.new(:message, :location)

    # The project root, which will be used to make the paths relative.
    # Defaults to `pwd`.
    # @param    [String] value
    # @return   [String]
    attr_accessor :project_root

    # A globbed string or array of strings which should match the files
    # that you want to ignore warnings on. Defaults to nil.
    # An example would be `'**/Pods/**'` to ignore warnings in Pods that your project uses.
    #
    # @param    [String or [String]] value
    # @return   [[String]]
    attr_accessor :ignored_files

    # A block that filters specific results.
    # An example would be `lambda { |result| result.message.start_with?('ld') }` to ignore results for ld_warnings.
    #
    # @param    [Block value
    # @return   [Block]
    attr_accessor :ignored_results

    # Defines if using inline comment or not.
    # Defaults to `false`.
    # @param    [Boolean] value
    # @return   [Boolean]
    attr_accessor :inline_mode

    # Defines if warnings should be included or not
    # Defaults to `false`.
    # @param    [Boolean] value
    # @return   [Boolean]
    attr_accessor :ignores_warnings

    # rubocop:disable Lint/DuplicateMethods
    def project_root
      root = @project_root || Dir.pwd
      root += '/' unless root.end_with? '/'
      root
    end

    def ignored_files
      [@ignored_files].flatten.compact
    end

    def ignored_results(&block)
      @ignored_results ||= block
    end

    def inline_mode
      @inline_mode || false
    end

    def ignores_warnings
      @ignores_warnings || false
    end

    # Pick a Dangerfile plugin for a chosen request_source and cache it
    # based on https://github.com/danger/danger/blob/master/lib/danger/plugin_support/plugin.rb#L31
    def plugin
      plugins = Plugin.all_plugins.select { |plugin| Dangerfile.essential_plugin_classes.include? plugin }
      @plugin ||= plugins.select { |p| p.method_defined? :html_link }.map { |p| p.new(@dangerfile) }.compact.first
    end
    # rubocop:enable Lint/DuplicateMethods

    # Reads a `.xcresult` and reports it.
    #
    # @param    [String] file_path Path for xcresult bundle.
    # @return   [void]
    def report(file_path)
      if File.exist?(file_path)
        xcode_summary = XCResult::Parser.new(path: file_path)
        format_summary(xcode_summary)
      else
        fail 'summary file not found'
      end
    end

    # Reads a `.xcresult` and reports its warning and error count.
    #
    # @param    [String] file_path Path for xcresult bundle.
    # @return   [String] JSON string with warningCount and errorCount
    def warning_error_count(file_path)
      if File.exist?(file_path)
        xcode_summary = XCResult::Parser.new(path: file_path)
        warning_count = 0
        error_count = 0
        xcode_summary.actions_invocation_record.actions.each do |action|
          warning_count += warnings(action).count
          error_count += errors(action).count
        end
        result = { warnings: warning_count, errors: error_count }
        result.to_json
      else
        fail 'summary file not found'
      end
    end

    private

    def format_summary(xcode_summary)
      xcode_summary.actions_invocation_record.actions.each do |action|
        warnings(action).each do |result|
          if inline_mode && result.location
            warn(result.message, sticky: false, file: result.location.file_path, line: result.location.line)
          else
            warn(result.message, sticky: false)
          end
        end
        # rubocop:disable Lint/UnreachableLoop
        errors(action).each do |result|
          if inline_mode && result.location
            fail(result.message, sticky: false, file: result.location.file_path, line: result.location.line)
          else
            fail(result.message, sticky: false)
          end
        end
        # rubocop:enable Lint/UnreachableLoop
      end
    end

    def warnings(action)
      return [] if ignores_warnings

      warnings = [
        action.action_result.issues.warning_summaries,
        action.build_result.issues.warning_summaries
      ].flatten.compact.map do |summary|
        result = Result.new(summary.message, parse_location(summary.document_location_in_creating_workspace))
        Result.new(format_warning(result), result.location)
      end
      warnings = warnings.uniq.reject { |result| result.message.nil? }
      warnings.delete_if(&ignored_results)
    end

    def errors(action)
      errors = [
        action.action_result.issues.error_summaries,
        action.build_result.issues.error_summaries
      ].flatten.compact.map do |summary|
        result = Result.new(summary.message, parse_location(summary.document_location_in_creating_workspace))
        Result.new(format_warning(result), result.location)
      end

      test_failures = [
        action.action_result.issues.test_failure_summaries,
        action.build_result.issues.test_failure_summaries
      ].flatten.compact.map do |summary|
        result = Result.new(summary.message, parse_location(summary.document_location_in_creating_workspace))
        Result.new(format_test_failure(result, summary.producing_target, summary.test_case_name),
                   result.location)
      end

      results = (errors + test_failures).uniq.reject { |result| result.message.nil? }
      results.delete_if(&ignored_results)
    end

    def parse_location(document_location)
      return nil if document_location.nil?

      file_path = document_location.url.gsub('file://', '').split('#').first
      file_name = file_path.split('/').last
      fragment = document_location.url.split('#').last
      params = CGI.parse(fragment).transform_values(&:first)
      number = params['StartingLineNumber']
      line = number.empty? ? 0 : number.to_i + 1 # StartingLineNumber is 0-based, but we need a 1-based value
      Location.new(file_name, relative_path(file_path), line)
    end

    def format_path(file_path, line)
      if plugin
        path = file_path
        path += "#L#{line}" if line
        plugin.html_link(path)
      else
        file_path
      end
    end

    def relative_path(path)
      return nil if project_root.nil?

      path.gsub(project_root, '')
    end

    def should_ignore_warning?(path)
      ignored_files.any? { |pattern| File.fnmatch(pattern, path) }
    end

    def escape_reason(reason)
      reason.gsub('>', '\>').gsub('<', '\<')
    end

    def format_warning(result)
      return escape_reason(result.message) if result.location.nil?

      path = result.location.file_path
      return nil if should_ignore_warning?(path)

      path_link = format_path(path, result.location.line)

      "**#{path_link}**: #{escape_reason(result.message)}"
    end

    def format_test_failure(result, producing_target, test_case_name)
      path = result.location.file_path
      path_link = format_path(path, result.location.line)
      suite_name = "#{producing_target}.#{test_case_name}"
      "**#{suite_name}**: #{escape_reason(result.message)}  <br />  #{path_link}"
    end
  end
end
