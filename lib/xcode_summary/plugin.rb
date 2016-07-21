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

    require 'json'
  
    # Reads file with JSON Xcode summary
    #
    # @param file_path String path for Xcode summary
    #
    # @return JSON object
    #
    def read_summary(file_path)
      if File.file?(file_path)
        JSON.parse(File.read(file_path), {:symbolize_names => true})
      else
        fail 'summary file not found'
      end
    end
    
    # Receive a JSON object with symbols as keys
    #
    # @param xcode_summary JSON object
    #
    # @return [void]
    #
    def format_summary(xcode_summary)
      messages = [
        xcode_summary[:tests_summary_messages]
      ].flatten.uniq.compact
      messages.each { |s| message(s, sticky: true) }

      warnings = [
        xcode_summary[:warnings],
        xcode_summary[:ld_warnings],
        xcode_summary[:compile_warnings].map { |s| format_compile_warning(s) }
      ].flatten.uniq.compact
      warnings.each { |s| warn(s, sticky: false) }

      errors = [
        xcode_summary[:errors],
        xcode_summary[:compile_errors].map { |s| format_compile_warning(s) },
        xcode_summary[:file_missing_errors].map { |s| format_format_file_missing_error(s) },
        xcode_summary[:undefined_symbols_errors].map { |s| format_undefined_symbols(s) },
        xcode_summary[:duplicate_symbols_errors].map { |s| format_duplicate_symbols(s) },
        xcode_summary[:tests_failures].map { |k, v| format_test_failure(k, v) }.flatten
      ].flatten.uniq.compact
      errors.each { |s| fail(s, sticky: false) }
    end
    
    private

    def url_for_path(path)
      commit = github.head_commit
      repo = env.request_source.pr_json[:head][:repo][:html_url]
      path = "/#{path}" unless path.start_with? '/'
      path, line = path.split(':')
      url = "#{repo}/blob/#{commit}#{path}"
      url += "#L#{line}" if line
    end

    def markdown_for_path(path)
      url = url_for_path(path)
      path[0] = '' if path.start_with? '/'
      "[#{path}](#{url})"
    end

    def format_path(path)
    # need to be more general
      workspace_path = File.expand_path('.')
      path = path.gsub(workspace_path, '') if workspace_path
      markdown_for_path(path)
    end

    def should_ignore_warning(path)
      path =~ %r{.*/Frameworks/.*\.framework/.*}
    end

    def format_compile_warning(h)
      return nil if should_ignore_warning(h[:file_path])

      path = format_path(h[:file_path])
      "**#{path}**: #{h[:reason]}  \n" \
        "```\n" \
        "#{h[:line]}\n" \
        "```  \n"
    end

    def format_format_file_missing_error(h)
      path = format_path(h[:file_path])
      "**#{h[:reason]}**: #{path}"
    end

    def format_undefined_symbols(h)
      "#{h[:message]}  \n" \
        "> Symbol: #{h[:symbol]}  \n" \
        "> Referenced from: #{h[:reference]}"
    end

    def format_duplicate_symbols(h)
      "#{h[:message]}  \n" \
        "> #{h[:file_paths].map { |path| path.split('/').last }.join("\n> ")}\n"
    end

    def format_test_failure(suite_name, failures)
      failures.map { |f|
        path = format_path(f[:file_path])
        "**#{suite_name}**: #{f[:test_case]}, #{f[:reason]}  \n  #{path}  \n"
      }
    end
    
  end
end
