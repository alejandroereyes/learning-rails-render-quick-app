#README

This is a tutorial app on better understand the rails render process. The following are a few notes I took during the course.

##Rails Inheritance
- Included modules are ancestors
- Methods are overridden in reverse
- `super` can be used inside a method to call to the its first ancestor's method.
- `class Parent` that includes `module Supportive`
 ```ruby
 puts Parent.ancestors
 Parent
 Supportive
 Object
 ```

- `class Child < Parent` that includes `module Supportive`
  ```ruby
  puts Child.ancestors
  Child
  Supportive
  Parent
  ```

- `class Child < Parent` that includes `module Supportive` and line below includes `module Detractive`
  ```ruby
  puts Child.ancestors
  Child
  Detractive
  Supportive
  Parent
  ```

##The Render Process

####`ActionPack` - <span><font size="3">The web request framework</font></span>

#####`ActionDispatch` - <span><font size="3">Take all of the requests, handles requests, routing, caching, etc...</font></span>


#####`AbstractController` - <span><font size="3">Shares all of its logic with ActionController & ActionMailer</font></span>


#####`Metal` - <span><font size="3">Bare bones Controller. Can be used to create a lightweight controller and only include the modules you want.</font></span>


#####`ActionController` - <span><font size="3">The Base class that all Rails application controllers inherit from. It's where all the modules are included.</font></span>


##The Resolver Process

####`ActionView` - <span><font size="3">Responsible for templates, helpers, resolvers rendering</font></span>

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
