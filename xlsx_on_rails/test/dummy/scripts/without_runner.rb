require 'abstract_controller'
require 'action_controller'
require 'action_view'
require 'active_record'
require 'xlsx_on_rails'

# helpers
require './app/helpers/application_helper'

# active record
require './app/models/widget'
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/development.sqlite3'
)

ActionController::Base.prepend_view_path "./app/views/"
view_assigns = {widgets: Widget.all}
av = ActionView::Base.new(ActionController::Base.view_paths, view_assigns)
av.class_eval do
  include ApplicationHelper
end

content = av.render template: 'widgets/index.xlsx.axlsx'
File.open("/tmp/with_runner.xlsx","w+b") {|f| f.puts content }
# `open /tmp/with_runner.xlsx`