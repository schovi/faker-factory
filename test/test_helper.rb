$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'faker_factory'
require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/reporters'
require 'pry'

Minitest::Reporters.use!(
  Minitest::Reporters::ProgressReporter.new,
  ENV,
  Minitest.backtrace_filter
)
