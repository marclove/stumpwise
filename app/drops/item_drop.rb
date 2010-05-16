class ItemDrop < BaseDrop
  liquid_attributes.push(*[
    :title, :slug, :show_in_navigation, :created_at, :updated_at,
    :root?, :child?, :leaf?, :landing_page?
    #:created_by, :updated_by
  ])
  
  def previous
    @source.previous.to_liquid if @source.previous
  end
  
  def next
    @source.next.to_liquid if @source.next
  end
  
  def parent
    @source.parent.to_liquid if @source.parent
  end
  
  def children
    @source.children.map(&:to_liquid)
  end
    
  def permalink
    "/#{@source.permalink}"
  end
end