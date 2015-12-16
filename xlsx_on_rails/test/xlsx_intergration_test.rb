require 'test_helper'

class XlsxIntegrationTest < ActionDispatch::IntegrationTest
  test "plain request sends html file" do
    get widgets_path
    assert_html_header 'index.html header'
    assert_html response.body, 'index.html body'
  end

  test "xlsx request sends xlsx file" do
    get widgets_path(format: :xlsx)
    assert_xlsx_header 'index.xlsx header'
    assert_spreadsheet response.body, 'index.xlsx body'
  end

  test "renders with extension" do
    get widgets_path(render: :with_extension)
    assert_xlsx_header 'index.xlsx header'
    assert_spreadsheet response.body, 'index.xlsx body'
  end

  test "renders with format" do
    get widgets_path(render: :with_format)
    assert_xlsx_header 'index.xlsx header'
    assert_spreadsheet response.body, 'index.xlsx body'
  end

  test "renders with render :xlsx" do
    get widgets_path(render: :render_xlsx)
    assert_equal "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", headers["Content-Type"], 'with_filename'
    assert_equal 'binary', headers["Content-Transfer-Encoding"]
    assert_spreadsheet response.body, 'index.xlsx body', 'Name 0'
  end

  test "renders with respond_with" do
    get '/widgets/with.xlsx'
    assert_equal "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", headers["Content-Type"], 'with_filename'
    assert_equal 'binary', headers["Content-Transfer-Encoding"]
    assert_spreadsheet response.body, 'index.xlsx body', 'Name 0'
  end

  test "sets the filename header" do
    get widgets_path(format: :xlsx, render: :with_filename)
    assert_equal 'binary', headers["Content-Transfer-Encoding"]
    assert_equal "attachment; filename=\"with_filename.xlsx\"", headers["Content-Disposition"]
    # assert_xlsx_header 'with_filename'
    assert_equal "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", headers["Content-Type"], 'with_filename'
  end

  test "emails template" do
    get '/widgets/xlsx'
    mail = ActionMailer::Base.deliveries.last
    assert_equal "To xlsx", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
    assert 1, mail.attachments.length
    assert_equal Mime::XLSX.to_s+'; charset=UTF-8', mail.attachments.first.content_type
    assert_spreadsheet mail.attachments.first.body, 'attachment body', 'Name 0'
  end
end
