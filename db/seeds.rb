# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

path = File.join(Rails.root, 'spec', 'fixtures', 'seeds')
payloads = ['categories', 'themes', 'reviews']
payloads.each do |payload|
  count = 0
  payload_json = JSON.parse(File.open(File.join(path, "#{payload}.json")).read)
  payload_class = payload.singularize.classify.constantize
  payload_json.each do |payload_record|
    payload_class.create!(payload_record) && (count+=1) unless payload_class.where(id: payload_record['id']).exists?
  end
  puts "Created #{count} out of #{payload_json.count} #{payload}"
end

puts 'Post-processing Reviews'
Review.set_new_category_and_theme_ids
Review.reindex
puts "Done post-processing #{Review.count} Reviews"
