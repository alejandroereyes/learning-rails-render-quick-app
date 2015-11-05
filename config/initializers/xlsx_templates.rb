Mime::Type.register "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", :xlsx

class XlsxTemplate
  def self.call(template)
    template.source
  end
end

# or
# handler = lambda { |template| template.source }

ActionView::Template.register_template_handler :axlsx,
  XlsxTemplate

  # index.xlsx.axlsx
  # 'Axlsx'
