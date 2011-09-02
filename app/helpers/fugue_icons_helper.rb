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
      "fugue-icon ".html_safe + options[:class]
    else
      "fugue-icon".html_safe
    end

    paths = options.delete(:shadow) ? ["icons".html_safe] : ["icons-shadowless".html_safe]
    if overlay = options.delete(:overlay)
      paths << "_overlay".html_safe
      name = "#{name}--#{overlay}".html_safe
    end
    paths << "#{name}.png".html_safe
    options[:src] = "/images/".html_safe + paths.join("/".html_safe)
    tag("img", options, false)
  end
end
