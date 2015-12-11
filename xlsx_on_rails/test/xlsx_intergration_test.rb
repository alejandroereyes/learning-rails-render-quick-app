require 'test_helper'
class XlsxIntegrationTest < ActionDispatch::IntegrationTest
  test "plain request send html file" do
    get widgets_path
    assert_equal "text/html; charset=utf-8", headers["Content-Type"],
      'index.html header'
      assert_match 'Description 0', response.body, 'index.html body'
  end

  test "xlsx request sends xlsx file" do
    get widgets_path(format: :xlsx)
    assert_equal "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; charset=utf-8", headers["Content-Type"], 'index.xlsx header'
    File.open('/tmp/xlsx_on_rails.xlsx', 'w') do |f|
      f.puts response.body
    end
    wb = nil
    assert_nothing_raised do
      wb = Roo::Excelx.new('/tmp/xlsx_on_rails.xlsx')#Roo::Spreadsheet.open('/tmp/xlsx_on_rails.xlsx')
    end
    assert_equal 'Description 0', wb.cell(2,2), 'index.xlsx body'
  end
end
