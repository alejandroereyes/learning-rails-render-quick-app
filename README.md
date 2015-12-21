#README

This is a tutorial app on better understand the rails v4.1.1 render process. The following is a brief overview of the rendering process taken from [Noel Peden's Rails Rendering course on Pluralsight](https://app.pluralsight.com/library/courses/rails-rendering/table-of-contents).

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

##Pre Render - <span><font size="3">Going through the controller action</font></span>

#####`ActionPack::AbstractController::Base`
 ```ruby
 # Called after middleware is done, called from Metal.
def process(action, *args)
  @_action_name = action_name = action.to_xlsx

  unless action_name = _find_action_name(action_name) # fill handle action missing, & handles rendering template even though method not present in controller.
    raise ActionNotFound, "The action '#{action}' could not be found for #{self.class.name}"
  end

  @_response_body = nil

  process_action(action_name, *args) # calls send_action which is alias for send, where aciton_name isn't necessarily the action name but a method name.
end
 ```

#####`ActionController::ImplicitRender`
```ruby
def send_action(method, *args)
  ret = super # calls method on controller
  default_render unless performed? # calls default render if rendering hasn't been performed which calls render with *args if render not explicitly called in controller(Rails MAGIC).
  ret
end
```

##The Render Process
Starts with `render` in the controller code and ends with `view.send(method_name, locals, ...)` in the view code.
- Controller::Render method call stack
  ```ruby
  render(*arg, &block) # this particular render is only overridden in 2 places, both inside of Metal, see Metal below.
    _normalize_render(*args, &block) # normalizes args & options(seperate action_name from options, and parse options values)
      _normalize_args(*args, &block) # In 3 places: AbstractController::Rendering(if no action name passed in), ActionController::Metal::Rendering(if a block is passed), ActionView::Rendering(handles action param, if a "/" is found then treats it as a file instead of action)
      -normalize_options(options) # In 4 places: AbstractController::Rendering(passes options back), ActionController::Metal::Rendering(hanles: escaped inline html, if nothing passed or nil format value, parses passed status code), ActionView::Layouts(hanles layout option or sets to default), ActionView::Rendering(hanles: partial: true, sets it to action_name; if none passed sets prefix arr - arr of strings to find templates; sets template to action_name if not already set)
    render_to_body(action, *args) # In 3 places: AbstractController::Rendering(does nothing), ActionController::Metal::Renderers(links in any custom renderer & then super), ActionController::Metal::Rendering(super || looks for inline options: html, text, etc || passes " "), ActionView::Rendering(process options & renders template)
      _process_options(options) # In 3 places: AbstractController::Rendering(passes back options), ActionController::Metal::Rendering(splits out header info & stores it inside of controller), ActionController::Metal::Streaming(sets headers if needed)
      _render_template(options) # In 2 places: ActionController::Metal::Streaming(passes back streamed version), ActionView::Rendering(hanles: :variant, :formats; gets appropriate renderer)
        view_renderer # ActionView::Renderer instance for specific context, renders that view
          ActionView::Renderer.new # With this instance, move into the view code
  ```

- View::Render method call stack
   ```ruby
   ActionView::Renderer.new(lookup context)
    render(context, options) # delegate to appropriate object,
      render_template(context, options) # in the case of a template, it calls render_template
        TemplateRenderer.new(lookup context) # in case of a partial, render_partial would have been a called and a partial renderer object would have been instantiated.
          render(context, options)
            determine_template(options) # uses a resolver to look up the file & return the source as a Template object
            render_template(template, layout, locals)
              render_with_layout(layout_name,...) # surrounds the template with a layout
                Template.render(view,locals) # Template here is a Template instance
                  compile(view, mod) # if not already done, Template object will compile the code into a method & insert into the Singleton class for the view context
                  view.send(method_name, locals, ...) # will send that method_name into the view  & return the results
   ```


####`ActionPack` - <span><font size="3">The web request framework</font></span>

##### `ActionDispatch` - <span><font size="3">Takes all of the requests, handles requests, routing, caching, etc...</font></span>

##### `AbstractController` - <span><font size="3">Shares all of its logic with ActionController & ActionMailer</font></span>
  - `render` is first defined in `actionpack/lib/abstract_controller/rendering.rb`.

  ```ruby
  def render(*args, &block)
    options = _normalize_render(*args, &block) # Both args and options are normalized by calling _normalize_args, which is defined in 3 places: abstract_controller/rendering.rb, action_controller/metal/rendering.rb(both in ActionPack), & action_view/rendering.rb(in ActionView).
    self.response_body = render_to_body(options)
    _process_format(rendered_format, options) if rendered_format
    self.response_body  
    end
  end

  ...
  # handles if you don't pass an action name in
  def _normalize_args(action=nil, options={})
    if action.is_a? Hash
      action
    else
      options
    end
  end
  ```

##### `Metal` - <span><font size="3">Bare bones Controller. Can be used to create a lightweight controller by only including the modules you want.</font></span>
  - Although the generic name "render" is used in multiple places inside of rails, the above mentioned `render` method is only overridden two times, both inside of `ActionController::Metal`.
  - `actionpack/lib/action_controller/metal/instrumentaion.rb` wraps the render method in a benchmark and logs how long it takes to render the view.

  ```ruby
  Benchmark.ms { render_output = super }
  ```
  - `actionpack/lib/action_controller/metal/rendering.rb` raises an error if a response has already been generated.

  ```ruby
  def render(*args)
    raise ::AbstractController::DoubleRenderError if self.response_body
    super
  end

  ...
  # handles if you pass a block and sets its return value to the update option.
  #  Isn't used as much because it would mean that inline code directly into the controller.
  def _normalize_args(action=nil, options={}, &blk) #:nodoc:  <--Interesting tidbit, the comment to the left is part of rails code, as a way to not have Rdoc document this. It's public facing but it's not meant for users. Checkout: http://guides.rubyonrails.org/api_documentation_guidelines.html#method-visibility  
    options = super
    options[:update] = blk if block_given?
    options
  end
  ```

##### `ActionView` - <span><font size="3">Being used to help normalize arguments during the render process.</font><span>
 - `actionview/lib/action_view/rendering.rb` handles what the action parameter is.

 ```ruby
 # Main point here is if action has a "/" in name, than it treats it as a file,
 #  allowing it to find something in separate directory.
 def _normalize_args(action=nil, options={})
   options = super(action, options)
   ...
     key = action.include?(?/) ? :file : :action
   ...
 ```

##### `ActionController` - <span><font size="3">The Base class that all Rails application controllers inherit from. It's where all the modules are included.</font></span>


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
