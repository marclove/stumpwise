require 'test_helper'
require 'liquid'

module Test
  module Unit
    module Assertions
        include Liquid
        def assert_template_result(expected, template, assigns={}, message=nil)
          assert_equal expected, Template.parse(template).render(assigns)
        end 
    end
  end
end

class LiquidFiltersTest < ActionView::TestCase
  include Liquid
  
  context "Custom Liquid filters" do
    setup do 
      @context = Context.new({},{:site => Site.new(:theme_id => 1)})
      
      def setup_vars(vars)
        vars.each_pair do |k,v|
          @context[k]=v
        end
      end
      
      def render_template(tpl)
        Variable.new(tpl).render(@context)
      end
    end
  
    context "for text" do
      should "textilize my text" do
        setup_vars('text' => "h1. My Title\n\n*This is really important.* But this, not so much.")
        assert_equal "<h1>My Title</h1>\n<p><strong>This is really important.</strong> But this, not so much.</p>", render_template("text | textilize")
      end
      
      should "truncate by number of characters" do
        setup_vars('var' => "My long text that I'm truncating")
        assert_equal "My long...", render_template("var | truncate:10")
      end
    
      should "truncate by number of words" do
        setup_vars('var' => "My long text that I'm truncating")
        assert_equal "My long...", render_template("var | truncate_words: 2")
        assert_equal "My long >>", render_template("var | truncate_words: 2, ' >>'")
      end
    
      should "prepend text" do
        setup_vars('var' => 'text')
        assert_equal 'prepended text', render_template('var | prepend:"prepended "')
      end
    
      should "append text" do
        setup_vars('var' => 'text')
        assert_equal 'text appended', render_template('var | append:" appended"')
      end
    
      should "capitalize text" do
        setup_vars('var' => "my sentence text")
        assert_equal 'My sentence text', render_template('var | capitalize')
      end
      
      should "format a time" do
        setup_vars('the_time' => Time.parse("February 3, 2010 3:25PM"))
        assert_equal "February  3, 2010  3:25PM", render_template("the_time | date: '%B %e, %Y %l:%M%p'")
      end
    
      should "downcase text" do
        setup_vars('var' => 'ALL UPPERCASE TEXT')
        assert_equal "all uppercase text", render_template('var | downcase')
      end
    
      should "escape html entities" do
        setup_vars('var' => '<strong>')
        assert_equal "&lt;strong&gt;", render_template('var | escape')
      end
    
      should "simple format text" do
        setup_vars('paragraphs' => "Here's a line break\nand a new paragraph...\n\n...right there.")
        assert_equal "<p>Here's a line break\n<br />and a new paragraph...</p>\n\n<p>...right there.</p>", render_template('paragraphs | simple_format')
      end
    
      should "given a number, pluralize a string" do
        assert_equal "5 Widgets", render_template('5 | pluralize: "Widget"')
        assert_equal "1 Widget", render_template('1 | pluralize: "Widget"')
        assert_equal "5 Foobard", render_template('5 | pluralize: "Foobar","Foobard"')
      end
    
      should "replace text" do
        assert_equal "baz bar baz", render_template('"foo bar foo" | replace: "foo", "baz"')
      end
    
      should "replace first occurence in text" do
        assert_equal "baz bar foo", render_template('"foo bar foo" | replace_first: "foo", "baz"')
      end
    
      should "remove text" do
        assert_equal "bar", render_template('"foobarfoo" | remove: "foo"')
      end
    
      should "remove first occurence of text" do
        assert_equal "barfoo", render_template('"foobarfoo" | remove_first: "foo"')
      end
    
      should "get the length of a string" do
        assert_equal 6, render_template('"foobar" | size')
      end
    
      should "strip html entities from a string" do
        assert_equal "foo", render_template('"<strong>foo</strong>" | strip_html')
      end
    
      should "strip new lines from a string" do
        setup_vars('text' => "foo\nbar\nbaz")
        assert_equal "foobarbaz", render_template('text | strip_newlines')
      end
    
      should "upcase text" do
        assert_equal "FOOBAR", render_template('"foobar" | upcase')
      end
    
      should "widont text" do
        assert_equal "foo bar&nbsp;baz", render_template('"foo bar baz" | widont')
      end
    
      should_eventually "format markdown text"
    
      should_eventually "format textilize text"
    end
    
    context "for HTML" do
      should "link to an item" do
        setup_vars('item' => {'permalink' => '/news', 'title' => 'News'})
        assert_equal '<a href="/news">News</a>', render_template("item | link_to_item")
        assert_equal '<a href="/news">Alt Text</a>', render_template('item | link_to_item:"Alt Text"')
      end
      
      should "include google javascript links" do
        assert_equal '<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.1/jquery.min.js" type="text/javascript"></script>', render_template('"jquery.1.4.1" | google_js')
        assert_equal '<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.4.1/jquery-ui.min.js" type="text/javascript"></script>', render_template('"jqueryui.1.4.1" | google_js')
        assert_equal '<script src="http://ajax.googleapis.com/ajax/libs/prototype/1.4.1/prototype.js" type="text/javascript"></script>', render_template('"prototype.1.4.1" | google_js')
        assert_equal '<script src="http://ajax.googleapis.com/ajax/libs/scriptaculous/1.4.1/scriptaculous.js" type="text/javascript"></script>', render_template('"scriptaculous.1.4.1" | google_js')
        assert_equal '<script src="http://ajax.googleapis.com/ajax/libs/mootools/1.4.1/mootools-yui-compressed.js" type="text/javascript"></script>', render_template('"mootools.1.4.1" | google_js')
        assert_equal '<script src="http://ajax.googleapis.com/ajax/libs/dojo/1.4.1/dojo/dojo.xd.js" type="text/javascript"></script>', render_template('"dojo.1.4.1" | google_js')
        assert_equal '<script src="http://ajax.googleapis.com/ajax/libs/swfobject/1.4.1/swfobject.js" type="text/javascript"></script>', render_template('"swfobject.1.4.1" | google_js')
        assert_equal '<script src="http://ajax.googleapis.com/ajax/libs/yui/1.4.1/build/yuiloader/yuiloader-min.js" type="text/javascript"></script>', render_template('"yui.1.4.1" | google_js')
        assert_equal '<script src="http://ajax.googleapis.com/ajax/libs/ext-core/1.4.1/ext-core.js" type="text/javascript"></script>', render_template('"ext-core.1.4.1" | google_js')
        assert_equal '<script src="http://ajax.googleapis.com/ajax/libs/chrome-frame/1.4.1/CFInstall.min.js" type="text/javascript"></script>', render_template('"chrome-frame.1.4.1" | google_js')
        assert_equal '', render_template('"unsupported" | google_js')
        # no version provided
        assert_equal '', render_template('"jquery" | google_js')
      end
    
      should_eventually "produce a gravatar for a user"
      
      should "produce javascript tags for theme javascript files" do
        assert_equal '<script src="http://s3.amazonaws.com/stumpwise-test/themes/1/application.js" type="text/javascript"></script>', render_template('"application" | javascript')
        assert_equal '<script src="http://s3.amazonaws.com/stumpwise-test/themes/1/jquery.js" type="text/javascript"></script><script src="http://s3.amazonaws.com/stumpwise-test/themes/1/application.js" type="text/javascript"></script>', render_template('"jquery,application" | javascripts')
      end
      
      should "produce stylesheet tags for theme stylesheets" do
        assert_equal '<link href="http://s3.amazonaws.com/stumpwise-test/themes/1/master.css" media="screen" rel="stylesheet" type="text/css" />', render_template('"master" | stylesheet')
        assert_equal '<link href="http://s3.amazonaws.com/stumpwise-test/themes/1/master.css" media="print" rel="stylesheet" type="text/css" />', render_template('"master" | stylesheet:"print"')
        assert_equal '<link href="http://s3.amazonaws.com/stumpwise-test/themes/1/base.css" media="screen" rel="stylesheet" type="text/css" /><link href="http://s3.amazonaws.com/stumpwise-test/themes/1/grids.css" media="screen" rel="stylesheet" type="text/css" />', render_template('"base,grids" | stylesheets')
      end
      
      should "produce a theme asset url" do
        assert_equal 'http://s3.amazonaws.com/stumpwise-test/themes/1/my_file.png', render_template('"my_file.png" | asset_url')
      end

      should "produce a theme image tag" do
        assert_equal '<img alt="" src="http://s3.amazonaws.com/stumpwise-test/themes/1/my_file.png" />', render_template('"my_file.png" | asset_image_tag')
      end
    end
    
    context "for Arrays" do
      should "select the first element" do
        setup_vars('var' => ['foo','bar','baz'])
        assert_equal "foo", render_template('var | first')
      end
      
      should "select item at an index" do
        setup_vars('var' => ['foo','bar','baz'])
        assert_equal "bar", render_template('var | index:1')
      end
      
      should "join elements" do
        setup_vars('var' => ['foo','bar','baz'])
        assert_equal "foo-bar-baz", render_template('var | join:"-"')
      end
      
      should "select the last element" do
        setup_vars('var' => ['foo','bar','baz'])
        assert_equal "baz", render_template('var | last')
      end
      
      should "map the attribute to the passed objects" do
        setup_vars('items' => [
          {'title' => 'Title 1', 'slug' => 'title-1'},
          {'title' => 'Title 2', 'slug' => 'title-2'},
          {'title' => 'Title 3', 'slug' => 'title-3'}
        ])
        assert_equal ['Title 1','Title 2','Title 3'], render_template('items | attribute:"title"')
      end
      
      should "know the number of elements" do
        setup_vars('var' => ['foo','bar','baz'])
        assert_equal 3, render_template('var | size')
      end
      
      should "sort an array" do
        setup_vars('var' => ['foo','bar','baz'])
        assert_equal ['bar','baz','foo'], render_template('var | sort')
      end

      should "sort an array of objects by an attribute" do
        setup_vars('items' => [
          {'title' => 'Title 2', 'slug' => 'title-2'},
          {'title' => 'Title 1', 'slug' => 'title-1'},
          {'title' => 'Title 3', 'slug' => 'title-3'}
        ])
        expected = [
          {'title' => 'Title 1', 'slug' => 'title-1'},
          {'title' => 'Title 2', 'slug' => 'title-2'},
          {'title' => 'Title 3', 'slug' => 'title-3'}
        ]
        assert_equal expected, render_template('items | sort:"title"') 
      end
      
      should "split a string into an array of strings" do
        setup_vars('list' => "1,2,3")
        assert_equal ["1","2","3"], render_template('list | split:","')
      end
      
      should "turn an array of strings into a sentence" do
        setup_vars('list1' => ['foo','bar','baz'], 'list2' => ['foo','bar'])
        assert_equal "foo, bar, and baz", render_template('list1 | to_sentence')
        assert_equal "foo and bar", render_template('list2 | to_sentence')
      end
    end
    
    context "for numbers" do
      should "convert a number of bytes into a human readable string" do
        assert_equal "1.8 MB", render_template('1894302 | number_to_human_size')
        assert_equal "1.8 MB", render_template('1894302 | readable_file_size')
      end
      
      should "convert a number to currency" do
        assert_equal "$1,483.85", render_template('1483.852 | currency')
        assert_equal "€1.483,85", render_template('1483.852 | currency: 2, "€", ".", ","') 
        assert_equal "1.483,852 #", render_template('1483.8521 | currency: 3, "#", ".", ",", "%n %u"') 
      end
      
      should "convert a number to a percentage" do
        assert_equal "1,552.56%", render_template('1552.5562 | percentage')
        assert_equal "1.552,6%", render_template('1552.5562 | percentage: 1, ".", ","')
      end
      
      should "convert a number to a phone number" do
        assert_equal "408-555-2324", render_template('4085552324 | phone_number')
        assert_equal "(408) 555-2324", render_template('4085552324 | phone_number:true')
        assert_equal "408.555.2324", render_template('4085552324 | phone_number:false,"."')
      end
      
      should "convert a number to a delimited string" do
        assert_equal "12,345,678.05", render_template('12345678.05 | delimiter')
        assert_equal "12.345.678,05", render_template('12345678.05 | delimiter:".",","')
      end
      
      should "convert a number to a string with precision" do
        assert_equal "111.23", render_template('111.23246 | precision:2')
      end
      
      should "divide numbers" do
        assert_equal 5, render_template('10 | divided_by:2')
      end
      
      should "subtract numbers" do
        assert_equal 5, render_template('7 | minus:2')
      end
      
      should "add numbers" do
        assert_equal 15, render_template('10 | plus:5')
      end
      
      should "multiply numbers" do
        assert_equal 20, render_template('10 | times:2')
      end
    end

  end
end
