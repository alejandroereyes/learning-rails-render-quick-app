S3Template = Struct.new(:key, :read, :last_modified, :obj)

class S3Rails
  attr_accessor :access_key_id, :secret_access_key, :region, :bucket_name, :bucket, :s3, :objects, :last_load

  def initialize(config_file)
    config = YAML::load(IO.read(config_file))
    @access_key_id = config['s3_rails']['access_key_id']
    @secret_access_key = config['s3_rails']['secret_access_key']
    @bucket_name = config['s3_rails']['bucket']
    @region = config['s3_rails']['region']
    @last_load = nil

    AWS.config(access_key_id: @access_key_id, secret_access_key: @secret_access_key, region: @region)

    @s3 = AWS::S3.new
    unless @s3.buckets[ @bucket_name ].nil?
      @bucket = @s3.buckets[ @bucket_name ]
    end

    load_cache
  end

  def buckets
    @s3.buckets
  end

  def load_cache
    Rails.logger.info "loading bucket"
    @objects = Hash[@bucket.objects.map {|o| [
        o.key,
        S3Template.new(o.key, o.read, o.last_modified, o)
      ]}]
    @last_load = Time.now
    Rails.logger.info "done"
  end
end

class S3Resolver < ActionView::PathResolver
  include Singleton
  attr_accessor :s3rails

  def initialize()
    super
    @s3rails = S3Rails.new('config/s3_rails.yml')
  end

  def build_query(path, details)
    exts = EXTENSIONS.map do |ext, prefix|
      "{" +
      details[ext].compact.uniq.map { |e| "#{prefix}#{e}," }.join +
      "}"
    end.join

    path.to_s + exts
  end

  def query(path, details, formats)
    query = build_query(path, details)

    if File.exists?('tmp/reload_s3.txt') &&
        @s3rails.last_load < File.mtime('tmp/reload_s3.txt')
      @s3rails.load_cache
      clear_cache
    end

    # objects = @s3rails.bucket.objects.with_prefix(path.prefix).select do |obj|
    #   File.fnmatch query, obj.key, File::FNM_EXTGLOB
    # end

    objects = @s3rails.objects.select do |key, obj|
      File.fnmatch query, key, File::FNM_EXTGLOB
    end

    objects.map do |key, obj|
      template = "s3/#{@s3rails.bucket_name}/#{obj.key}"
      handler, format, variant =
        extract_handler_and_format_and_variant(template, formats)
      contents = obj.read

      ActionView::Template.new(contents, template, handler,
        :virtual_path => path.virtual,
        :format       => format,
        :variant      => variant,
        :updated_at   => obj.last_modified
      )
    end
  end
end
