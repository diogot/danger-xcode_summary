# danger-xcode_summary

[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](LICENSE.txt)
[![Gem](https://img.shields.io/gem/v/danger-xcode_summary?style=flat)](http://rubygems.org/gems/danger-xcode_summary)
[![Build Status](https://travis-ci.org/diogot/danger-xcode_summary.svg?branch=master)](https://travis-ci.org/diogot/danger-xcode_summary)

A [Danger](http://danger.systems) plugin that shows all build errors, warnings and unit tests results generated from `xcodebuild`.

You need to use [xcpretty](https://github.com/supermarin/xcpretty) with 
[xcpretty-json-formatter](https://github.com/marcelofabri/xcpretty-json-formatter) 
to generate a JSON file that this plugin can read.

## Installation

Add this line to your Gemfile:

```ruby
gem 'danger-xcode_summary'
```

## Usage

Just add this line to your `Dangerfile`:

```ruby
xcode_summary.report 'xcodebuild.json'
```

You can also ignore warnings from certain files by setting `ignored_files`: 

```ruby
# Ignoring warnings from Pods
xcode_summary.ignored_files = '**/Pods/**'
xcode_summary.report 'xcodebuild.json'
```

## License

MIT

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.
