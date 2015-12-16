class ActiveRecord::Base
  def to_xlsx
    xlsx_package = Axlsx::Package.new
    xlsx_package.workbook.add_worksheet(:name => "Widgets") do |sheet|
      names = attributes.keys
      sheet.add_row names
      sheet.add_row attributes.values_at(*names)
    end
    xlsx_package.to_stream.string
  end
end

class Array
  def to_xlsx
    xlsx_package = Axlsx::Package.new
    xlsx_package.workbook.add_worksheet(:name => "Widgets") do |sheet|
      names = first.attributes.keys
      sheet.add_row names
      each do |obj|
        sheet.add_row obj.attributes.values_at(*names)
      end
    end
    xlsx_package.to_stream.string
  end
end
