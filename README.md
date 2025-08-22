# danger-xcode_summary

[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](LICENSE.txt)
[![Gem Version](https://badge.fury.io/rb/danger-xcode_summary.svg)](https://badge.fury.io/rb/danger-xcode_summary)
[![Build Status](https://travis-ci.org/diogot/danger-xcode_summary.svg?branch=master)](https://travis-ci.org/diogot/danger-xcode_summary)

A [Danger](http://danger.systems) plugin that shows all build errors, warnings and unit tests results generated from `xcodebuild`.

## How does it look?

<table>
  <thead>
    <tr>
      <th width="50"></th>
      <th width="100%">
          1 Error
      </th>
     </tr>
  </thead>
  <tbody>
    <tr>
      <td><g-emoji alias="no_entry_sign" fallback-src="https://assets-cdn.github.com/images/icons/emoji/unicode/1f6ab.png">🚫</g-emoji></td>
      <td>
<strong>MyWeightTests.MyWeightTests</strong>: testError, failed - :w:  <br>  <a href="https://github.com/Invariante/MyWeight/blob/0101261efd67cd1fb0d682d88476fdee3d17cf86/MyWeightTests/MyWeightTests.swift#L26">MyWeightTests/MyWeightTests.swift#L26</a>
</td>
    </tr>
  </tbody>
</table>

<table>
  <thead>
    <tr>
      <th width="50"></th>
      <th width="100%">
          2 Warnings
      </th>
     </tr>
  </thead>
  <tbody>
    <tr>
      <td><g-emoji alias="warning" fallback-src="https://assets-cdn.github.com/images/icons/emoji/unicode/26a0.png">⚠️</g-emoji></td>
      <td>
<strong><a href="https://github.com/Invariante/MyWeight/blob/0101261efd67cd1fb0d682d88476fdee3d17cf86/MyWeight/ViewController.swift#L35">MyWeight/ViewController.swift#L35</a></strong>: initialization of immutable value ‘bla’ was never used; consider replacing with assignment to ‘_’ or removing it  <br><code>
        let bla = "unused variable"
</code>
</td>
    </tr>
    <tr>
      <td><g-emoji alias="warning" fallback-src="https://assets-cdn.github.com/images/icons/emoji/unicode/26a0.png">⚠️</g-emoji></td>
      <td>
<strong><a href="https://github.com/Invariante/MyWeight/blob/0101261efd67cd1fb0d682d88476fdee3d17cf86/Bla.m#L32">Bla.m#L32</a></strong>: Value stored to ‘theme’ is never read  <br><code>
            theme = *ptr++;
</code>
</td>
    </tr>
  </tbody>
</table>

<table>
  <thead>
    <tr>
      <th width="50"></th>
      <th width="100%">
          1 Message
      </th>
     </tr>
  </thead>
  <tbody>
    <tr>
      <td><g-emoji alias="book" fallback-src="https://assets-cdn.github.com/images/icons/emoji/unicode/1f4d6.png">📖</g-emoji></td>
      <td>TestTarget: Executed 5 tests, with 1 failure (0 unexpected) in 0.032 (0.065) seconds</td>
    </tr>
      </tr>
  </tbody>
</table>

## Installation

Add this line to your Gemfile:

```ruby
gem 'danger-xcode_summary'
```

## Usage

Just add this line to your `Dangerfile`:

```ruby
xcode_summary.report 'MyApp.xcresult'
```

You need to pass the path of the `xcresult` generated after compiling your app.
By default, this is inside the `DerivedData` for your project, but you can use the `-resultBundlePath`
flag when calling `xcodebuild` to customize its path. You can read more about it in this [blog post from the folks at PSPDFKit](https://pspdfkit.com/blog/2021/deflaking-ci-tests-with-xcresults/#using-xcresult-bundles).

You can also ignore warnings from certain files by setting `ignored_files`: 
Warning: `ignored_files` patterns applied on relative paths.  

```ruby
# Ignoring warnings from Pods
xcode_summary.ignored_files = 'Pods/**'

# Ignoring specific warnings
xcode_summary.ignored_results { |result|
  result.message.include? 'ld' # Ignore ld_warnings
}

xcode_summary.report 'MyApp.xcresult'

# When `true`, collapses parallelized test runs of the same target into one line.
# Defaults to `false`.
xcode_summary.collapse_parallelized_tests = true
```

You can use `ignores_warnings` to supress warnings and shows only errors.

```ruby
xcode_summary.ignores_warnings = true
```

You can use `inline_mode`.
When this value is enabled, each warnings and errors are commented on each lines.

```ruby
# Comment on each lines
xcode_summary.inline_mode = true
xcode_summary.report 'MyApp.xcresult'
```

You can use `ignore_retried_tests` to intelligently handle retried unit tests.
When enabled, if a test fails but succeeds on retry, the failure will be ignored and not reported as an error.

```ruby
# Ignore test failures that succeeded on retry
xcode_summary.ignore_retried_tests = true
xcode_summary.report 'MyApp.xcresult'
```

You can use `strict` to reporting errors as warnings thereby don't block merge PR.

 ```ruby
 # If value is `false`, then errors will be reporting as warnings
 xcode_summary.strict = false
 ```

You can get warning and error number by calling `warning_error_count`. The return will be a JSON string contains warning and error count, e.g `{"warnings":1,"errors":3}`:

```ruby
result = xcode_summary.warning_error_count 'MyApp.xcresult'
```

## License

danger-xcode_summary is released under the MIT license. See [LICENSE.txt](LICENSE.txt) for details.

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.
