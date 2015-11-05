require 'test_helper'

class XlsxTemplateHandlerTest < ActiveSupport::TestCase
  test 'mime type' do
    assert Mime.const_defined?('XLSX') # Mime::XLSX
    assert_equal Mime::XLSX.to_sym, :xlsx
    assert_equal Mime::XLSX.to_s, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  test 'handler exists' do
    assert XlsxOnRails.const_defined?('TemplateHandler')
    assert XlsxOnRails::TemplateHandler.respond_to?(:call)
    assert_equal Mime::XLSX, XlsxOnRails::TemplateHandler.new.default_format
  end

  test 'handler is registered' do
    assert ActionView::Template.template_handler_extensions.include?('axlsx')
  end
end
