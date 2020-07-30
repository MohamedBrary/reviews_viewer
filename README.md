## Creating ReviewsViewer Rails Project

### Table of Contents

* [Initialization](#initialization)
* [Gems](#gems)
  + [Haml and Bootstrap](#haml-and-bootstrap)
  + [Utilities](#utilities)
    - [Cheerful console and environment variables gems](#cheerful-console-and-environment-variables-gems)
    - [Sprockets issue with Rails 6](#sprockets-issue-with-rails-6)
* [Generating Models](#generating-models)
* [Deploy to Heroku](#deploy-to-heroku)
* [Commentary](#commentary)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

### Initialization
Based on this [gist](https://gist.github.com/MohamedBrary/12465abb009d5dbeadeb8cde9adb30b5) .
```sh
# List available rubies, to choose which ruby to use
$ rvm list rubies

# To install new ruby use, for example version '2.7.1'
$ rvm install 2.7.1

# create and use the new RVM gemset for project "reviews_viewer"
$ rvm use --create 2.7.1@reviews_viewer

# install latest rails into the blank gemset
$ gem install rails -v 6.0.3

# as a good practice is recommended to install webpack and webpack-dev-server locally, more info [here](https://webpack.js.org/guides/installation/).
$ yarn add webpack webpack-dev-server webpack-cli --dev

# Creates new rails app "reviews_viewer"
# -d mysql: defining database (other options: mysql, oracle, postgresql, sqlite3, frontbase)
# -T to skip generating test folder and files (in case of planning to use rspec)
# --api to create an API only application
$ rails new reviews_viewer -d postgresql -T

# go into the new project directory and create a .ruby-version and .ruby-gemset for the project
$ cd reviews_viewer
$ rvm --ruby-version use 2.7.1@reviews_viewer

```

### Gems

#### Haml and Bootstrap

Using Haml and Bootstrap to have simple nice looking views

```ruby
gem 'haml-rails'
gem 'bootstrap-generators' # to generate views using bootstrap
gem 'will_paginate-bootstrap4' # pagination but with bootstrap touch
```

```sh
$ rake haml:erb2haml
$ rails generate bootstrap:install --template-engine=haml
```

#### Utilities

##### Cheerful console and environment variables gems

```ruby
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  # More colorful console gems
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'pry-byebug'

  # Handling env variables
  gem 'dotenv-rails'
end
```

##### Sprockets issue with Rails 6

I had to use this specific version, to solve an issue with assets compiling.

```ruby
gem 'sprockets', '~> 3.7.2'
```

```sh
$ bundle update sprockets
```

##### Test gems

I am using Rspec framework, and 'rspec_api_documentation' [gem](https://github.com/zipmark/rspec_api_documentation), which is very nice, it makes you follow TDD for your API, so you write down the API request signature, add your tests, and at the same time it takes these info and generate a nice looking API documentation (found at doc/api/index.html that can be exposed as a public route)

```ruby
group :development, :test do
  ...

  # Using Rspec testing framework
  gem 'rspec-rails'
  gem 'rspec_api_documentation'
  gem 'database_cleaner-active_record'

  ...
end
```

```sh
$ rails generate rspec:install
$ rspec # should run without errors
$ mkdir spec/acceptance # create the spec folder for 'rspec_api_documentation'
.
. # create your tests
.
$ rake docs:generate # to generate the API documentation from the acceptance tests
```

##### Data generator gems

For a lot of reasons, having the ability to generate records with random and semi-realistic feel is precious;
- whether for usage in test suite,
- creating some records from console easily,
- used in populators, that would allow you to populate your development or staging environment with data, and also allow you to benchmark your application performance against different sizes of data

I use combination of [FactoryBot](https://github.com/thoughtbot/factory_bot_rails) and [Faker](https://github.com/faker-ruby/faker) to have fixture factories with random info, also [Populator](https://github.com/ryanb/populator) to create masses of records with higher performance.

```ruby
# Gemfile
# Using FactoryBot, Faker, and Populator as the suite for data generation
# Adding them to all environments, as I am planning to expose data generation on heroku
gem 'factory_bot_rails'
gem 'faker', git: 'https://github.com/faker-ruby/faker.git', branch: 'master'
gem 'populator'
```

### Running Application

##### Making sure webpacker is working properly

```sh
$ bundle
$ bundle exec rails webpacker:install
```

##### Configuring .env and database.yml

Create `.env` file and add these two environment variables

```ruby
# DBs Credentials
LOCAL_DB_USERNAME='your_db_username'
LOCAL_DB_PASSWORD='your_db_password'
```

So we can use them in `config/database.yml` to configure development and test databases.

```yml
...
development:
  <<: *default
  database: reviews_viewer_development
  username: <%= ENV['LOCAL_DB_USERNAME'] %>
  password: <%= ENV['LOCAL_DB_PASSWORD'] %>
...
test:
  <<: *default
  database: reviews_viewer_test
  username: <%= ENV['LOCAL_DB_USERNAME'] %>
  password: <%= ENV['LOCAL_DB_PASSWORD'] %>
...

```

Now we can create the database, and run Rails server to make sure that our application has been initialized successfully.

```sh
$ rails db:create
$ rails s
# now visit localhost:3000 in your browser to see the application running
```

##### Initializing git repository and first commit

```sh
# initialize git
$ git init
$ git add .
$ git commit -m 'CHORE: initial commit with new rails app and initial gems'
$ git remote add origin git@github.com:MohamedBrary/reviews_viewer.git
$ git push -u origin master
```

### Generating Models

```sh
# generate scaffold for models to speed up the creation of the app
# for the sake of this sample task, we will deal with the external id, as the internal id (won't save the external id)
# we will also create some duplicate foriegn key fields, and composite foriegn keys fields, to play with them later to tune the performance of database
rails g scaffold Category name
rails g scaffold Theme name category:references
rails g scaffold Review comment:index posted_at theme_ids:integer:index category_ids:integer:index
rails g scaffold ReviewTheme review:references theme:references category:references sentiment:integer
```

### Deploy to Heroku

You need first to have an account on [Heroku](https://signup.heroku.com/?c=70130000001x9jFAAQ), and Heroku [command line interface](https://devcenter.heroku.com/articles/heroku-cli#download-and-install) installed.

```sh
# Creating new Heroku app named reviews_viewer
$ heroku create reviews-viewer

# Deploy application
$ git push heroku master

# To open heroku app
$ heroku open

# Useful heroku commands
$ heroku logs --tail
$ heroku run rails console

```

**Click [here](https://reviews-viewer.herokuapp.com/) to open the heroku app.**

### Commentary

- I wanted to use Rails 6, and had some issues with sprockets verions and webpack usage
- I am aiming to use Postgres indexes (nice SO thread [here](https://stackoverflow.com/questions/1566717/postgresql-like-query-performance-variations)) to speed up the required querying
  + My understanding that we value retrieval over creating performance, as I would assume that creating reviews and processing them is a background job, while retrieving data and statistics is a client facing feature, and it is vital to be responsive.
- If I have time, I am also planning to use ElasticSearch, and create a denormalized index suitable for the queries we need, and then provide some benchmarking for both ways
- Also if there is enough time, I will create some generators and fakers to be able to generate different sizes of data, and have better benchmarks
