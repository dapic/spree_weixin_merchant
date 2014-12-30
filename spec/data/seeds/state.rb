country = Spree::Country.find_by(name: 'China')

Spree::State.create!([
  { name: '北京市', abbr: 'BJ', country: country }
  { name: '上海市', abbr: 'SH', country: country }
])
