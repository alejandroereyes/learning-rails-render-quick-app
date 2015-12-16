require 'test_helper'

class XlsxMailerTest < ActionMailer::TestCase
  test "widgets" do
    mail = WidgetMailer.to_xlsx Widget.all
    assert_equal "To xlsx", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
    assert 1, mail.attachments.length
    assert_equal Mime::XLSX.to_s+'; charset=UTF-8', mail.attachments.first.content_type
    assert_spreadsheet mail.attachments.first.body, 'attachment body', 'Name 0'
  end
end
