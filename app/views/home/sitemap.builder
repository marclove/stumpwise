xml.instruct! :xml, :version => '1.0'
xml.tag! 'urlset', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  xml.tag! 'url' do
    xml.tag! 'loc', "http://stumpwise.com/"
    xml.tag! 'lastmod', '2010-08-30'
    xml.tag! 'changefreq', 'weekly'
    xml.tag! 'priority', '1.0'
  end
  xml.tag! 'url' do
    xml.tag! 'loc', "https://secure.stumpwise.com/signup"
    xml.tag! 'lastmod', '2010-08-30'
    xml.tag! 'changefreq', 'weekly'
    xml.tag! 'priority', '0.9'
  end
end