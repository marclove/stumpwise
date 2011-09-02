register_liquid_tags = lambda do
  Liquid::Template.register_filter(Stumpwise::Liquid::Filters)
  Liquid::Template.register_tag('twitter_widget', Stumpwise::Liquid::Tags::TwitterWidget)
  Liquid::Template.register_tag('facebook_widget', Stumpwise::Liquid::Tags::FacebookWidget)
  Liquid::Template.register_tag('link_to', Stumpwise::Liquid::Tags::ItemLink)
  Liquid::Template.register_tag('pagination', Stumpwise::Liquid::Tags::Pagination)
end
 
Stumpwise::Application.configure do
  config.to_prepare(&register_liquid_tags)
end