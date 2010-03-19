Liquid::Template.register_filter(Stumpwise::Liquid::Filters)
Liquid::Template.register_tag('twitter', Stumpwise::Liquid::Tags::Twitter)
Liquid::Template.register_tag('link_to', Stumpwise::Liquid::Tags::ItemLink)
Liquid::Template.register_tag('pagination', Stumpwise::Liquid::Tags::Pagination)