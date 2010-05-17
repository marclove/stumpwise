class PageDrop < ItemDrop
  liquid_attributes.push(*[ :body ])
  
  def id
    @source.id
  end

  def html_id
    "page-#{@source.id}"
  end
end