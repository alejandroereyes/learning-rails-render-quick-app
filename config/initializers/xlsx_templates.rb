Mime::Type.register "application/vnd.openxmlformats-officedocument.spreadsheet.sheet", :xlsx

class XlsxTemplate
  def self.call(template)
    template.source
  end
end

ActionView::Template.register_template_handler :axlsx,
  XlsxTemplate

  # index.xlsx.axlsx
