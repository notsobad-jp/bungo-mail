source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.4'

gem 'rails', '7.0.3'
gem 'pg'
gem 'puma'
gem 'uglifier'
gem 'haml-rails'
gem 'jbuilder'
gem 'bootsnap', require: false
gem 'sorcery'
gem 'dotenv-rails'
gem 'delayed_job_active_record'
gem 'pundit'
gem 'kaminari'
gem 'rails-i18n'
gem 'stripe'
gem 'pragmatic_tokenizer'
gem 'pragmatic_segmenter'
gem 'lemmatizer'
gem 'google-api-client'
gem 'trigram' # 文字列の類似度チェック
gem "tailwindcss-rails"
gem 'propshaft'
gem 'importmap-rails'
gem 'turbo-rails'
gem 'web-push'
gem 'stimulus-rails'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'web-console'
  gem 'listen'
  gem 'letter_opener'
  gem 'letter_opener_web'
  gem "rack-dev-mark"
  gem 'sitemap_generator'
end

group :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
  gem 'webmock'
  gem 'vcr'
end

group :production do
  gem 'scout_apm'
end
