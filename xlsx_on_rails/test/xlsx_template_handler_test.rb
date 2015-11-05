require 'test_helper'

class XlsxTemplateHandlerTest < ActiveSupport::TestCase
  test 'mime type' do
    assert Mime.const_defined?('XLSX') # Mime::XLSX
    assert_equal Mime::XLSX.to_sym, :xlsx
    assert_equal Mime::XLSX.to_s, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end
end
  
