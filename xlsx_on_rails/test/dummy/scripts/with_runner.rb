# view_assigns = {widgets: Widget.all}
# @view_assigns = Widget.all
# av = ActionView::Base.new(ActionController::Base.view_paths, view_assigns)
# av.class_eval do
  # include ApplicationHelper
# end

# content = av.render template: 'widgets/index.xlsx.axlsx'
content = Widget.all.to_xlsx
File.open("/tmp/with_runner.xlsx","w+b") {|f| f.puts content }
`open /tmp/with_runner.xlsx`