class Admin::NavigationsController < ApplicationController
  handles_sorting_of_nested_set
  
  def show
    @items = current_site.navigation
  end
  
  def update
    new_position = position_of(:moved_item_id).in_tree(:item)
    item = Item.find(params[:moved_item_id])
    [:move_to_right_of, :move_to_left_of].each do |m|
      item.send(m, new_position[m]) if new_position[m]
    end
    render :nothing => true
  end
end
