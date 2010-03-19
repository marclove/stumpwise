require 'test_helper'
require 'liquid'

class ItemDropTest < Test::Unit::TestCase
  include Liquid
  
  context "Item Drop" do
    setup do
      @attributes = {
        :site_id => Mongo::ObjectID.new,
        :slug => "kundesmith-kundesmith-kundesmith",
        :title => "Aut Qui Animi",
        :published => true,
        :template_name => "template.tpl",
        :show_in_navigation => false,
        :created_by => nil,
        :updated_by => nil
        #path => ["kundesmith-kundesmith-kundesmith"]
        #path_size => 1,
        #permalink => "/kundesmith-kundesmith-kundesmith",
        #position => 1,
        #ancestor_ids => [],
        #_type => "Page",
        #parent_id => nil,
      }
      @item = Item.create(@attributes).to_liquid
    end
    
    should "have slug attribute" do
      assert_equal @attributes[:slug], @item['slug']
    end
    
    should "have title attribute" do
      assert_equal @attributes[:title], @item['title']
    end
    
    should "have show_in_navigation attribute" do
      assert_equal @attributes[:show_in_navigation], @item['show_in_navigation']
    end
    
    should "have created_by attribute" do
      assert_equal @attributes[:created_by], @item['created_by']
    end
    
    should "have updated_by attribute" do
      assert_equal @attributes[:updated_by], @item['updated_by']
    end
    
    should "have root? attribute" do
      assert @item['root?']
    end
    
    should_eventually "have access to its self and siblings"
    
    should_eventually "have access to its siblings"
    
    should_eventually "have access to its parent"
    
    should_eventually "have access to its children"
  end
end