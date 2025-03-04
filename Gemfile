source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.3'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

gem 'sprockets', '~> 3.7.2'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  # More colorful console gems
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'pry-byebug'

  # Using Rspec testing framework
  gem 'rspec-rails'
  gem 'database_cleaner-active_record'

  # Handling env variables
  gem 'dotenv-rails'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Using haml and bootstrap for simple views
gem 'haml-rails'
gem 'bootstrap-generators' # to generate views using bootstrap
gem 'will_paginate-bootstrap4' # pagination but with bootstrap touch

# used for 'rspec_api_documentation' gem to enhance generated documentation
gem 'rspec_api_documentation'
gem "apitome", github: "jejacks0n/apitome"

# Using FactoryBot, Faker, and BulkInsert as the suite for data generation
# Adding them to all environments, as I am planning to expose data generation on heroku
gem 'factory_bot_rails'
gem 'faker', git: 'https://github.com/faker-ruby/faker.git', branch: 'master'
gem 'bulk_insert'

# Using ElasticSearch 7.x(7.8.1), which is on latest branch currently
gem 'elasticsearch-model', github: 'elastic/elasticsearch-rails'
gem 'elasticsearch-rails', github: 'elastic/elasticsearch-rails'
