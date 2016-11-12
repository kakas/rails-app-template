def remove_gems(*names)
  names.each do |name|
    gsub_file 'Gemfile', /^gem '#{name}'.*\n/, ''
  end
end

def remove_comment_of_gem
  gsub_file 'Gemfile', /^\s*#.*\n/, ''
end

def replace_from_remote(src, dest = nil)
  dest ||= src
  repo = 'https://raw.github.com/kakas/rails-app-template/master/files/'
  remote_file = repo + src
  remove_file dest
  get(remote_file, dest)
end

remove_comment_of_gem

# gitignore
replace_from_remote('gitignore', '.gitignore')

# bootstrap sass
if yes?("Apply bootstrap3?")
  say 'Applying bootstrap3...'
  gem 'bootstrap_form'
  gem 'bootstrap-sass'
  remove_file 'app/assets/stylesheets/application.css'
  replace_from_remote('application.scss', 'app/assets/stylesheets/application.scss')
  inject_into_file 'app/assets/javascripts/application.js', after: "//= require jquery\n" do "//= require bootstrap-sprockets\n" end
end

# font-awesome
say 'Applying font-awesome...'
gem 'font-awesome-sass', '~> 4.7.0'

# carrierwave
say 'Applying carrierwave and mini_magick...'
gem 'carrierwave', '>= 1.0.0.rc', '< 2.0'
gem 'mini_magick'
# replace_from_remote('image_uploader.rb', 'app/uploaders/image_uploader.rb')

say 'Applying rails-i18n...'
gem 'rails-i18n', '~> 5.0.0'

say 'Applying debug tools...'
gem_group :development, :test do
  gem 'meta_request'
  gem 'bullet'
  gem 'rails-erd'
  gem 'pry-byebug'
  gem 'faker'
end

say 'Applying basic application config...'
inject_into_file 'config/application.rb', after: "class Application < Rails::Application\n" do
  <<-EOF
    config.generators.assets = false
    config.generators.helper = false
    config.time_zone = 'Taipei'
    config.i18n.available_locales = [:en, :'zh-TW']
    config.i18n.default_locale = :'zh-TW'
  EOF
end

after_bundle do
  say 'Done! init `git` and `database`...'
  git :init
  git add: '.'
  git commit: '-m "init commit"'

  say "Build successfully! `cd #{app_name}` and use `rails s` to start your rails app..."
end
