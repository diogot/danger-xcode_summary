require 'json'

module Danger
  # This is your plugin class. Any attributes or methods you expose here will
  # be available from within your Dangerfile.
  #
  # To be published on the Danger plugins site, you will need to have
  # the public interface documented. Danger uses [YARD](http://yardoc.org/)
  # for generating documentation from your plugin source, and you can verify
  # by running `danger plugins lint` or `bundle exec rake spec`.
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Ensure people are well warned about merging on Mondays
  #
  #          my_plugin.warn_on_mondays
  #
  # @see  diogot/danger-xcode_summary
  # @tags monday, weekends, time, rattata
  #
  class DangerXcodeSummary < Plugin
    attr_writer :project_root

    def project_root
      @project_root || Dir.pwd
    end

    # Reads file with JSON Xcode summary and reports it.
    #
    # @param file_path String path for Xcode summary
    #
    # @return JSON object
    #
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
      messages(xcode_summary).each { |s| message(s, sticky: true) }
      warnings(xcode_summary).each { |s| warn(s, sticky: false) }
      errors(xcode_summary).each { |s| fail(s, sticky: false) }
    end

    def messages(xcode_summary)
      [
        xcode_summary[:tests_summary_messages]
      ].flatten.uniq.compact.map(&:strip)
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
      path = path.gsub(project_root, '') if project_root
      regex = /^(.*?):(\d*):?\d*$/
      match = path.match(regex)
      if match
        clean_path, line = match.captures
        path = clean_path + '#L' + line if clean_path && line
      end

      github.html_link(path)
    end

    def should_ignore_warning(path)
      path =~ %r{.*/Frameworks/.*\.framework/.*} || path =~ %r{.*/Pods/.*}
    end

    def escape_reason(reason)
      reason.tr('>', "\>").tr('<', "\<")
    end

    def format_compile_warning(h)
      return nil if should_ignore_warning(h[:file_path])

      path = format_path(h[:file_path])
      "**#{path}**: #{escape_reason(h[:reason])}  <br />" \
        "```\n" \
        "#{h[:line]}\n" \
        '```'
    end

    def format_format_file_missing_error(h)
      path = format_path(h[:file_path])
      "**#{escape_reason(h[:reason])}**: #{path}"
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
        path = format_path(f[:file_path])
        "**#{suite_name}**: #{f[:test_case]}, #{escape_reason(f[:reason])}  <br />  #{path}"
      end
    end
  end
end
