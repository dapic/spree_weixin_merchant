# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


#Spree::Core::Engine.load_seed if defined?(Spree::Core)
#Spree::Auth::Engine.load_seed if defined?(Spree::Auth)
Spree::Country.create!([ { name: 'China', iso: 'CN', iso3: 'CHN', iso_name: 'CHINA', numcode: 156 }])

country = Spree::Country.find_by(name: 'China')

Spree::State.create!([
  { name: '北京市', abbr: 'BJ', country: country },
  { name: '上海市', abbr: 'SH', country: country },
  { name: '广东', abbr: 'GD', country: country },
])
