require 'json'

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
      @test_summary .nil? ? true : @test_summary
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
      warnings(xcode_summary).each { |s| warn(s, sticky: false) }
      errors(xcode_summary).each { |s| fail(s, sticky: false) }
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
        xcode_summary[:warnings],
        xcode_summary[:ld_warnings],
        xcode_summary.fetch(:compile_warnings, {}).map { |s| format_compile_warning(s) }
      ].flatten.uniq.compact
    end

    def errors(xcode_summary)
      [
        xcode_summary[:errors],
        xcode_summary.fetch(:compile_errors, {}).map { |s| format_compile_warning(s) },
        xcode_summary.fetch(:file_missing_errors, {}).map { |s| format_format_file_missing_error(s) },
        xcode_summary.fetch(:undefined_symbols_errors, {}).map { |s| format_undefined_symbols(s) },
        xcode_summary.fetch(:duplicate_symbols_errors, {}).map { |s| format_duplicate_symbols(s) },
        xcode_summary.fetch(:tests_failures, {}).map { |k, v| format_test_failure(k, v) }.flatten
      ].flatten.uniq.compact
    end

    def format_path(path)
      clean_path, line = parse_filename(path)
      path = clean_path + '#L' + line if clean_path && line

      if defined? github
        github.html_link(path)
      elsif defined? bitbucket_server
        bitbucket_server.html_link(path)
      end
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

    def format_test_failure(suite_name, failures)
      failures.map do |f|
        path = relative_path(f[:file_path])
        path_link = format_path(path)
        "**#{suite_name}**: #{f[:test_case]}, #{escape_reason(f[:reason])}  <br />  #{path_link}"
      end
    end
  end
end
