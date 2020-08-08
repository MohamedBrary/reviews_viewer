## Creating ReviewsViewer Rails Project

### Table of Contents

- [Initialization](#initialization)
- [Gems](#gems)
  * [Haml and Bootstrap](#haml-and-bootstrap)
  * [Utilities](#utilities)
    + [Cheerful console and environment variables gems](#cheerful-console-and-environment-variables-gems)
    + [Sprockets issue with Rails 6](#sprockets-issue-with-rails-6)
    + [Test gems](#test-gems)
    + [Data generator gems](#data-generator-gems)
- [Running Application](#running-application)
    + [Making sure webpacker is working properly](#making-sure-webpacker-is-working-properly)
    + [Configuring .env and database.yml](#configuring-env-and-databaseyml)
    + [Initializing git repository and first commit](#initializing-git-repository-and-first-commit)
- [Generating Models](#generating-models)
- [Deploy to Heroku](#deploy-to-heroku)
- [Running Application Locally](#running-application-locally)
- [Commentary & TODOs](#commentary---todos)
- [Postgres vs. ElasticSearch Querying Benchmark](#postgres-vs-elasticsearch-querying-benchmark)

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
  gem 'database_cleaner-active_record'
  gem 'rspec_api_documentation'
  gem 'apitome' # used for 'rspec_api_documentation' gem to enhance generated documentation

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
$ rails generate apitome:install
$ rake docs:generate # to generate the API documentation from the acceptance tests
```

##### Data generator gems

For a lot of reasons, having the ability to generate records with random and semi-realistic feel is precious;
- whether for usage in test suite,
- creating some records from console easily,
- used in populators, that would allow you to populate your development or staging environment with data, and also allow you to benchmark your application performance against different sizes of data

I use combination of [FactoryBot](https://github.com/thoughtbot/factory_bot_rails) and [Faker](https://github.com/faker-ruby/faker) to have fixture factories with random info, also [BulkInsert](https://github.com/jamis/bulk_insert) to create masses of records with higher performance.

```ruby
# Using FactoryBot, Faker, and BulkInsert as the suite for data generation
# Adding them to all environments, as I am planning to expose data generation on heroku
gem 'factory_bot_rails'
gem 'faker', git: 'https://github.com/faker-ruby/faker.git', branch: 'master'
gem 'bulk_insert'
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

### Running Application Locally

- This is a Rails 6 application, that uses Postgres as its database (You need Postgres 9.1 or later so it would support the type of indexes we created, we also require 'pg_trgm' and 'intarray' extensions)
- Copy 'env.sample' file to '.env', and fill in your local database username and password
- Follow the RVM instructions in [here](#initialization) to create a gemset for this application before running 'bundle install'
- Run 'rails db:create db:migrate db:seed' to create and populate your local database
- Run 'rails s' to run the server, and use the browser to open the application on 'localhost:3000', the homepage should guide you through using the application

### Commentary & TODOs

- I wanted to use Rails 6, and had some issues with sprockets version and webpack usage
- I wanted to test the performance of both Postgres database vs Elasticsearch, and see how both would scale against different data sizes
- I used Postgres indexes (nice SO thread [here](https://stackoverflow.com/questions/1566717/postgresql-like-query-performance-variations)) to speed up the required querying
  + My understanding that we value retrieval over creating performance, as I would assume that creating reviews and processing them is a background job, while retrieving data and statistics is a client facing feature, and it is vital to be responsive.
- I used ElasticSearch, and created a denormalized index suitable for the queries we need
- I created some data generators and fakers to be able to generate different sizes of data, and have better benchmarks for querying against postgres vs elasticsearch
- TODO Adding Rubocop, and have better test coverage for the service classes
- TODO Formatting the API result need a better look, following any specification, would be much better, like JsonAPI for example
- TODO Add support to [test elasticsearch](https://bonsai.io/blog/testing-elasticsearch-ruby-gems.html), and add section to the readme for installing and running it locally and on Heroku

### Postgres vs. ElasticSearch Querying Benchmark

```sh
rake data:benchmark
Benchmarking 100 sample queries for {:categories_num=>169, :reviews_num=>8032692}, yielded these results:
Total time spent in database 0.031034868443384767
                Vs. in index 0.008404920226894319
So time in database was 3.69x in index!
```

- I implemented data generators that would generate a near-real full records, with all relations and fields are set properly
- More than 8M reviews were generated locally, with categories and themes
- The above benchmark is based on 100 queries that filter on review comment, category ids, and theme ids
- Each query was random, so it doesn't run the same query 100 times (I noticed Elasticsearch would out-perform PG drastically in case of repeated queries, maybe better caching, but can be tuned in PG if it is an actual real usage case )
- Definitely this isn't 100% accurate, and not a verdict, but would agree with the general notion of having Postgres as the data store, while using search engine for indexing and querying data, is one of the easy steps for scaling
- I do believe that most modern systems can be utilized in a way to scale with great performance, but it is a matter of which state the product in, and what are the available resources we can spare
