base_url = current_site.root_url
atom_feed do |feed|
  feed.title(@item.title)
  feed.updated(@item.updated_at)
  @item.articles.each do |article|
    feed.entry(article, :url => base_url + '/' + article.to_param) do |entry|
      entry.title(h(article.title))
      entry.content(article.body, :type => 'html')
      entry.author do |author|
        author.name(article.creator.name)
      end
    end
  end
end