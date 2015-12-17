#README

This is a tutorial app on better understand the rails render process. The following are a few notes I took during the course.

##The Render Process

####`ActionPack` - <span><font size="3">The web request framework</font></span>

#####`ActionDispatch` - <span><font size="3">Take all of the requests, handles requests, routing, caching, etc...</font></span>


#####`AbstractController` - <span><font size="3">Shares all of its logic with ActionController & ActionMailer</font></span>


#####`Metal` - <span><font size="3"></font></span>


#####`ActionController` - <span><font size="3"></font></span>


##The Resolver Process

####`ActionView` - <span><font size="3">Responsible for templates, helpers & rendering</font></span>

#####`ActionView::TemplateRenderer` - <span><font size="3">Finds and rendering the template</font></span>

#####`ActionView::LookupContext` - <span><font size="3">Holds all of the info needed to find a template</font></span>
  - Example: `widgets/index.en.html+iphone.erb`
    - `widgets` = prefix
    - `index` = name
    - `en` = locale
    - `html` = format
    - `iphone` = variant
    - `erb` = renderer

#####`ActionView::SetPath` - <span><font size="3">A way to access paths or resolvers</font></span>
  - Will take `path`, and array of `prefixes`, and `*args`, loop through every resolver sending info and first one that sends a response will be used. All resolvers must have `find_all` method in order for this to work.

#####`ActionView::Resolver` - <span><font size="3">Find and return a template given a set of details from the LookupContext</font></span>
```ruby
# Normalizes the args & passes them to find_templates
def find_all(name, prefix=nil, partial=false, details={}, key=nil, locals=[])
  # if template hasn't been cached or in dev mode & cached template has expired, it loads them again performing the block with find_templates.
  cached(key, [prefix, partial], details, locals) do
    find_templates(name, prefix, partial, details)
    end
  end
```
#####`ActionView::Template` - <span><font size="3">Wraps the template source</font></span>
  - To instantiate a Template

```ruby
# contents = binary of a file path, template = is that file, handler is extracted from that template
Template.new(contents, File.expand_path(template), handler,
  :virtual_path => path.virtual, # need for internationalization, in a view you can use the shortcut ex: <%= t('.title') %> and virtual path(widgets/index) will be used to look in config/locales/en.yml to find en: \n widgets: \n index: \n title: "English Widgets"
  :format       => format,
  :variant      => variant,
  :updated_at   => mtime(template)
  )
```
