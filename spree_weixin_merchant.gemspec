# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_weixin_merchant'
  s.version     = '2.3.2'
  s.summary     = 'This Spree extension deals with orders from Weixin Merchant (微信小店)'
  s.description = 'For orders placed within Weixin\'s "Shop" （微信小店), Weixin would send a notification to a pre-configured URL. This package deals with that notification'
  s.required_ruby_version = '>= 1.9.3'

  s.author    = 'Stanley Yeh'
  s.email     = 'stanley.yeh@foxmail.com'
  s.homepage  = 'http://github.com/dapic/spree_weixin_merchant'

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 2.3.2'
  s.add_dependency 'money', '< 7.0.0'
  s.add_dependency 'weixin_merchant'

  s.add_development_dependency 'capybara', '~> 2.1'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.4'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 3.1'
  s.add_development_dependency 'sass-rails', '~> 4.0.2'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
end
