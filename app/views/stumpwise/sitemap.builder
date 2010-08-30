xml.instruct! :xml, :version => '1.0'
xml.tag! 'urlset', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  for item in current_site.items do
    xml.tag! 'url' do
      xml.tag! 'loc', "#{current_site.root_url}/#{item.permalink}"
      xml.tag! 'lastmod', item.updated_at.strftime('%Y-%m-%d')
      xml.tag! 'changefreq', 'monthly'
      xml.tag! 'priority', '0.5'
    end
  end
end