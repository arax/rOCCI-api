source "https://rubygems.org/"

gemspec

group :development do
  gem 'vcr', :git => 'git://github.com/arax/vcr.git', :branch => 'test_framework_patches', :ref => 'e82e843ceddd8822acea59846b015bcabf1906df'
  gem 'rubygems-tasks', :git => 'git://github.com/postmodern/rubygems-tasks.git'
end

platforms :jruby do
  gem 'jruby-openssl' if ((defined? JRUBY_VERSION) && (JRUBY_VERSION.split('.')[1].to_i < 7))
end

platforms :ruby_18 do
    gem 'oniguruma'
end
