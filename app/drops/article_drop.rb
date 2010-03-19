class ArticleDrop < ItemDrop
  liquid_attributes.push(*[ :body ])

  def blog
    @source.blog.to_liquid
  end
end
