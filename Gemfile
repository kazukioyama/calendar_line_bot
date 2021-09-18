# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem "rails", '6.0.3.1'

gem 'mysql2'

gem 'puma'

gem 'faraday'

gem 'line-bot-api'

# Google認証用gem
gem 'googleauth'

# GoogleCalendarAPI叩く用gem
gem 'google-api-client'

gem 'signet'

gem 'pry-rails'

gem 'listen' # Add `gem 'listen'` to the development group of your Gemfile (LoadError) と怒られたので追加

gem 'dotenv-rails'

group :development, :test do
  gem 'rspec-rails', '~> 3.6'
end