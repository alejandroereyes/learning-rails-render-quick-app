# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require 'roo'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

def assert_html_header(msg = nil)
  assert_equal "text/html; charset=utf-8", headers["Content-Type"], msg
end

def assert_xlsx_header(msg = nil)
  assert_equal "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; charset=utf-8", headers["Content-Type"], msg
end

def assert_html(content, msg = nil, test_value = 'Description 0')
  assert_match test_value, content
end

def assert_spreadsheet(content, msg = nil, test_value = 'Description 0')
  File.open('/tmp/xlsx_on_rails.xlsx','w+b') {|f| f.puts content}
  wb = nil
  assert_nothing_raised do
    wb = Roo::Excelx.new('/tmp/xlsx_on_rails.xlsx')
  end
  assert_equal test_value, wb.cell(2,2), msg
end
