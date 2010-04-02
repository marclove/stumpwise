Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'campaign_monitor'
  s.version     = "1.3.3"
  s.summary     = 'Provides access to the Campaign Monitor API.'
  s.description = <<-EOF
    A simple wrapper class that provides basic access to the Campaign Monitor API.
  EOF
  s.author      = 'Jeremy Weiskotten'
  s.email       = 'jweiskotten@patientslikeme.com'
  s.homepage    = 'http://github.com/reidab/campaign_monitor/'
  s.has_rdoc    = true
  
  s.requirements << 'none'
  s.require_path = 'lib'

  s.add_dependency 'xml-simple', ['>= 1.0.11']
  s.add_dependency 'soap4r', ['>= 1.5.8']
 
  s.files = [
      'campaign_monitor.gemspec',
      'init.rb',
      'install.rb',
      'MIT-LICENSE',
      'Rakefile',
      'README.rdoc',
      'TODO',
      
      'lib/campaign_monitor.rb',
      'lib/campaign_monitor/base.rb',
      'lib/campaign_monitor/misc.rb',
      'lib/campaign_monitor/campaign.rb',
      'lib/campaign_monitor/client.rb',
      'lib/campaign_monitor/helpers.rb',
      'lib/campaign_monitor/list.rb',
      'lib/campaign_monitor/result.rb',
      'lib/campaign_monitor/subscriber.rb',
      
      'support/class_enhancements.rb',
      'support/faster-xml-simple/lib/faster_xml_simple.rb',
      'support/faster-xml-simple/test/regression_test.rb',
      'support/faster-xml-simple/test/test_helper.rb',
      'support/faster-xml-simple/test/xml_simple_comparison_test.rb',
      
      'test/campaign_monitor_test.rb',
      'test/campaign_test.rb',
      'test/client_test.rb',
      'test/list_test.rb',
      'test/test_helper.rb'
    ]

  s.test_file = 'test/campaign_monitor_test.rb'
end