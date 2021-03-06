module SortableElementForNestedSet
  # Calculate the new position of a moved tree within a nested set.
  # The new placement and sort order is given as a hash, as created by draggable_element 
  # Javascript helper.
  class TreeMoveCalculator
    attr_reader :nodes
    
    # Calculate the left, right and parent values from 
    # the parameter generated by draggable_element JS helper
    def initialize(sort_order)
      @nodes = TreeMoveCalculator.create_tree_nodes(sort_order)
    end
    
    def right_of(target_id)
      array_with_target_node = find_array_with_target_node(target_id)
  
      if (array_with_target_node.last.id == target_id)
        return nil
      else 
        return array_with_target_node[array_with_target_node.collect(&:id).index(target_id) + 1].id
      end
    end
    
    def placement_of(target_id)
      # Note that this swaps left and right as the consumer views it differently.
      
      {:parent => parent_of(target_id),
       :move_to_right_of => left_of(target_id),
       :move_to_left_of => right_of(target_id) }
    end
    
    def left_of(target_id)
      array_with_target_node = find_array_with_target_node(target_id)
      
      if (array_with_target_node.first.id == target_id)
        return nil
      else 
        return array_with_target_node[array_with_target_node.collect(&:id).index(target_id) - 1].id
      end
    end
      
    def parent_of(val_to_find) 
      return nil if @nodes.collect(&:id).include?(val_to_find)
  
      parent = nil
      
      @nodes.each do |node|
        parent = find_parent_of(val_to_find, node)
        return parent if parent
      end
    end
  
    # Create Array of TreeNodes from the parameter generated by draggable_element JS helper.
    def self.create_tree_nodes(tree)
      tree = to_hash(tree) if tree.is_a?(Array)
      
      result = []
      
      tree.keys.sort.each do |key|
        node = TreeNode.new(tree[key]["id"].to_i)
        node.children = create_tree_nodes( tree[key].reject {|k, v| k == "id"} )  if tree[key].many?
        result << node
      end
      
      return result
    end
    
    # Convert an array of ids to the required hash format. 
    def self.to_hash(array)
      result = {}
      
      array.each_with_index {|id, i| result[i.to_s] = {"id" => id.to_s } }
      
      return result
    end
  
  private  
    def root?(target_id)
      parent = parent_of(target_id)
      parent.nil?
    end
    
    def find_array_with_target_node(target_id)
      unless root?(target_id)
        parent_node_of(target_id).children
      else
        @nodes
      end
    end
  
    def parent_node_of(target_id)
      parent_node = (flattened_nodes.select {|x| x.id == parent_of(target_id) }).first
    end
    
    def flattened_nodes
      @flattened_nodes ||= flatten_node_tree(@nodes).flatten
    end
    
    def find_parent_of(val_to_find, node)
      return node.id if node.children.collect(&:id).include?(val_to_find)
         
      parent = nil 
      node.children.each do |child|
        parent = find_parent_of(val_to_find, child)
        return parent if parent
      end
      
      return nil
    end
    
    def flatten_node_tree(nodes) 
      result = []
      result << nodes
      
      (nodes.select{|x| !x.children.empty?}).each {|x| result << flatten_node_tree(x.children)}
      return result 
    end
  
  end

  class TreeNode
    attr_accessor :id, :children, :parent_id
    attr_accessor :left, :right
    
    def initialize(id, children = nil)
      @id = id
      @children = children.nil? ? [] : children
    end
    
    def children=(new_children)
      new_children.each {|c| c.parent_id = self.id }
      @children = new_children
    end
  end

end