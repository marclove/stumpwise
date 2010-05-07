class ActionController::Dispatcher
  class << self
    def register_liquid_tags
      Liquid::Template.register_filter(Stumpwise::Liquid::Filters)
      Liquid::Template.register_tag('twitter_widget', Stumpwise::Liquid::Tags::TwitterWidget)
      Liquid::Template.register_tag('facebook_widget', Stumpwise::Liquid::Tags::FacebookWidget)
      Liquid::Template.register_tag('link_to', Stumpwise::Liquid::Tags::ItemLink)
      Liquid::Template.register_tag('pagination', Stumpwise::Liquid::Tags::Pagination)
    end

    def cleanup_application_with_liquid
      returning cleanup_application_without_liquid do
        register_liquid_tags
      end
    end
    alias_method :cleanup_application_without_liquid, :cleanup_application
    alias_method :cleanup_application, :cleanup_application_with_liquid
  end
end

ActionController::Dispatcher.register_liquid_tags