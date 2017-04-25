require 'json'
require 'pathname'

module Danger
  # Shows all build errors, warnings and unit tests results generated from `xcodebuild`.
  # You need to use [xcpretty](https://github.com/supermarin/xcpretty)
  # with [xcpretty-json-formatter](https://github.com/marcelofabri/xcpretty-json-formatter)
  # to generate a JSON file that this plugin can read.
  # @example Showing summary
  #
  #          xcode_summary.report 'xcodebuild.json'
  #
  # @example Filtering warnings in Pods
  #
  #          xcode_summary.ignored_files = '**/Pods/**'
  #          xcode_summary.report 'xcodebuild.json'
  #
  # @see  diogot/danger-xcode_summary
  # @tags xcode, xcodebuild, format
  #
  class DangerXcodeSummary < Plugin
    Struct.new('Location', :file_name, :file_path, :line)
    Struct.new('Result', :message, :location)

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

    # Defines if the test summary will be sticky or not.
    # Defaults to `false`.
    # @param    [Boolean] value
    # @return   [Boolean]
    attr_accessor :sticky_summary

    # Defines if the build summary is shown or not.
    # Defaults to `true`.
    # @param    [Boolean] value
    # @return   [Boolean]
    attr_accessor :test_summary

    # Defines if using inline comment or not.
    # Defaults to `false`.
    # @param    [Boolean] value
    # @return   [Boolean]
    attr_accessor :inline_mode

    def project_root
      root = @project_root || Dir.pwd
      root += '/' unless root.end_with? '/'
      root
    end

    def ignored_files
      [@ignored_files].flatten.compact
    end

    def sticky_summary
      @sticky_summary || false
    end

    def test_summary
      @test_summary.nil? ? true : @test_summary
    end

    def inline_mode
      @inline_mode || false
    end

    # Reads a file with JSON Xcode summary and reports it.
    #
    # @param    [String] file_path Path for Xcode summary in JSON format.
    # @return   [void]
    def report(file_path)
      if File.file?(file_path)
        xcode_summary = JSON.parse(File.read(file_path), symbolize_names: true)
        format_summary(xcode_summary)
      else
        fail 'summary file not found'
      end
    end

    private

    def format_summary(xcode_summary)
      messages(xcode_summary).each { |s| message(s, sticky: sticky_summary) }
      warnings(xcode_summary).each do |result|
        if inline_mode && result.location
          warn(result.message, sticky: false, file: result.location.file_name, line: result.location.line)
        else
          warn(result.message, sticky: false)
        end
      end
      errors(xcode_summary).each do |result|
        if inline_mode && result.location
          fail(result.message, sticky: false, file: result.location.file_name, line: result.location.line)
        else
          fail(result.message, sticky: false)
        end
      end
    end

    def messages(xcode_summary)
      if test_summary
        [
          xcode_summary[:tests_summary_messages]
        ].flatten.uniq.compact.map(&:strip)
      else
        []
      end
    end

    def warnings(xcode_summary)
      [
        xcode_summary.fetch(:warnings, []).map { |message| Struct::Result.new(message, nil) },
        xcode_summary.fetch(:ld_warnings, []).map { |message| Struct::Result.new(message, nil) },
        xcode_summary.fetch(:compile_warnings, {}).map do |h|
          Struct::Result.new(format_compile_warning(h), parse_location(h))
        end
      ].flatten.uniq.compact.reject { |result| result.message.nil? }
    end

    def errors(xcode_summary)
      [
        xcode_summary[:errors],
        xcode_summary.fetch(:compile_errors, {}).map do |h|
          Struct::Result.new(format_compile_warning(h), parse_location(h))
        end,
        xcode_summary.fetch(:file_missing_errors, {}).map do |h|
          Struct::Result.new(format_format_file_missing_error(h), parse_location(h))
        end,
        xcode_summary.fetch(:undefined_symbols_errors, {}).map do |h|
          Struct::Result.new(format_undefined_symbols(h), nil)
        end,
        xcode_summary.fetch(:duplicate_symbols_errors, {}).map do |h|
          Struct::Result.new(format_duplicate_symbols(h), nil)
        end,
        xcode_summary.fetch(:tests_failures, {}).map do |test_suite, failures|
          failures.map do |failure|
            Struct::Result.new(format_test_failure(test_suite, failure), parse_test_location(failure))
          end
        end
      ].flatten.uniq.compact.reject { |result| result.message.nil? }
    end

    def parse_location(h)
      file_path, line, _column = h[:file_path].split(':')
      Struct::Location.new(h[:file_name], file_path, line.to_i)
    end

    def parse_test_location(failure)
      path, line = failure[:file_path].split(':')
      file_name = relative_path(path)
      Struct::Location.new(file_name, path, line.to_i)
    end

    def format_path(path)
      clean_path, line = parse_filename(path)
      path = clean_path + '#L' + line if clean_path && line

      # Pick a Dangerfile plugin for a chosen request_source
      # based on https://github.com/danger/danger/blob/master/lib/danger/plugin_support/plugin.rb#L31
      plugins = Plugin.all_plugins.select { |plugin| Dangerfile.essential_plugin_classes.include? plugin }
      plugin = plugins.select { |p| p.method_defined? :html_link }.map { |p| p.new(@dangerfile) }.compact.first

      plugin.html_link(path)
    end

    def parse_filename(path)
      regex = /^(.*?):(\d*):?\d*$/
      match = path.match(regex)
      if match
        match.captures
      end
    end

    def relative_path(path)
      return nil if project_root.nil?
      path.gsub(project_root, '')
    end

    def should_ignore_warning?(path)
      parsed = parse_filename(path)
      path = parsed.first || path
      ignored_files.any? { |pattern| File.fnmatch(pattern, path) }
    end

    def escape_reason(reason)
      reason.gsub('>', '\>').gsub('<', '\<')
    end

    def format_compile_warning(h)
      path = relative_path(h[:file_path])
      return nil if should_ignore_warning?(path)

      path_link = format_path(path)

      warning = "**#{path_link}**: #{escape_reason(h[:reason])}  <br />"
      if h[:line] && !h[:line].empty?
        "#{warning}" \
          "```\n" \
          "#{h[:line]}\n" \
          '```'
      else
        warning
      end
    end

    def format_format_file_missing_error(h)
      path = relative_path(h[:file_path])
      path_link = format_path(path)
      "**#{escape_reason(h[:reason])}**: #{path_link}"
    end

    def format_undefined_symbols(h)
      "#{h[:message]}  <br />" \
        "> Symbol: #{h[:symbol]}  <br />" \
        "> Referenced from: #{h[:reference]}"
    end

    def format_duplicate_symbols(h)
      "#{h[:message]}  <br />" \
        "> #{h[:file_paths].map { |path| path.split('/').last }.join('<br /> ')}"
    end

    def format_test_failure(suite_name, failure)
      path = relative_path(failure[:file_path])
      path_link = format_path(path)
      "**#{suite_name}**: #{failure[:test_case]}, #{escape_reason(failure[:reason])}  <br />  #{path_link}"
    end
  end
end
