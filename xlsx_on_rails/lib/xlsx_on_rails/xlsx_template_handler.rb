Mime::Type.register "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", :xlsx

module XlsxOnRails
  class TemplateHandler
    def self.call(template)
      template.source
    end

    def default_format
      Mime::XLSX
    end
  end
end
