class WidgetMailer < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.widget_mailer.to_xlsx.subject
  #
  def to_xlsx(widgets)
    @greeting = "Hi"

    # @widgets = widgets
    # xlsx = render_to_string 'widgets/index.xlsx.axlsx'
    xlsx = widgets.to_xlsx

    attachments["widgets.xlsx"] = {mime_type: Mime::XLSX, content: xlsx}

    mail to: "to@example.org"
  end
end
