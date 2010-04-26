module FugueIconsHelper
  # Returns an html image tag for the fugue icon specified with <tt>name</tt>.
  # <tt>name</tt> should not include an overlay suffix or file extension.
  # 
  # ==== Options
  # * <tt>:shadow</tt> - If set to true, the path for icons with shadows will be used. Defaults to false.
  # * <tt>:overlay</tt> - The name of the overlay you want to use. Defaults to nil.
  def icon_tag(name, options={})
    options.symbolize_keys!

    options[:class] = if options[:class]
      "fugue-icon " + options[:class]
    else
      "fugue-icon"
    end

    paths = options.delete(:shadow) ? ["icons"] : ["icons-shadowless"]
    if overlay = options.delete(:overlay)
      paths << "_overlay"
      name = "#{name}--#{overlay}"
    end
    paths << "#{name}.png"
    options[:src] = "/images/" + paths.join("/")
    tag("img", options)
  end
end
