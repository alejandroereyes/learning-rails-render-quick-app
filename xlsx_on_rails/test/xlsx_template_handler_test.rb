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

  test 'compiles a spreadsheet' do
    VT = Struct.new(:source)
    template = VT.new(
                      "xlsx_package = Axlsx::Package.new
                      wb = xlsx_package.workbook
                      wb.add_worksheet(name: 'Test') do |sheet|
                        sheet.add_row ['one', 'two', 'three']
                        sheet.add_row ['a', 'b', 'c']
                      end
                      xlsx_package.to_stream.string
                      ")
    content = eval(XlsxOnRails::TemplateHandler.call template)
    File.open('/tmp/xlsx_on_rails.xlsx', 'w') { |f| f.puts content }
    wb = nil
    assert_nothing_raised do
      wb = Roo::Excelx.new('/tmp/xlsx_on_rails.xlsx')
    end
    assert_equal 'b', wb.cell(2,2), 'template compiles'
  end
end
