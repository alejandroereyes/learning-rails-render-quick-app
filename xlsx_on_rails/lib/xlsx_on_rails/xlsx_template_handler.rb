Mime::Type.register "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", :xlsx

module XlsxOnRails
  class TemplateHandler
    def self.call(template)
      "xlsx_package = Axlsx::Package.new\n" +
      template.source +
      "\nxlsx_package.to_stream.string"
    end

    def default_format
      Mime::XLSX
    end
  end
end

ActionView::Template.register_template_handler :axlsx, XlsxOnRails::TemplateHandler
