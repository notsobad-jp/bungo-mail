source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.1'
gem 'rails', '8.0.1'

gem "bcrypt"
gem 'bootsnap', require: false
gem 'csv'
gem 'dotenv-rails'
gem 'delayed_job_active_record'
gem 'google-api-client'
gem 'haml-rails'
gem 'icalendar'
gem 'importmap-rails'
gem 'jbuilder'
gem 'kaminari'
gem 'lemmatizer'
gem 'pg'
gem 'pragmatic_segmenter'
gem 'pragmatic_tokenizer'
gem 'propshaft'
gem 'puma'
gem 'pundit'
gem 'rails-i18n'
gem 'stimulus-rails'
gem 'stripe'
gem "tailwindcss-rails"
gem 'trigram' # 文字列の類似度チェック
gem 'uglifier'
gem 'turbo-rails'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'letter_opener'
  gem 'letter_opener_web'
  gem 'listen'
  gem "rack-dev-mark"
  gem 'sitemap_generator'
  gem 'web-console'
end

group :test do
  gem 'minitest-rails'
  gem 'minitest-spec-context'
end

group :production do
  gem 'scout_apm'
end
