require 'test_helper'

class ToXlsxTest < ActiveSupport::TestCase
  test "ActiveRecord object creates a spreadsheet" do
    content = Widget.first.to_xlsx
    assert_spreadsheet content, 'ar.to_xlsx body', 'Name 0'
  end

  test "Array object creates a spreadsheet" do
    content = Widget.all.to_xlsx
    assert_spreadsheet content, 'ar.to_xlsx body', 'Name 0'
  end
end
