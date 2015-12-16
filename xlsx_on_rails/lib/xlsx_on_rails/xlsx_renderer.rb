ActionController::Renderers.add :xlsx do |obj, options|
  if obj.respond_to?(:to_xlsx)
    filename = 'widgets.xlsx'
    contents = obj.to_xlsx
  else
    filename = File.basename(obj, '.xlsx') + '.xlsx'
    contents = render_to_string(options)
  end
  send_data contents, :filename => filename, :type => Mime::XLSX, :disposition => 'attachment'
end
