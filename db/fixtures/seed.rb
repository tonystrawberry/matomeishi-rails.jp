User.seed do |user|
  user.id    = 1
  user.email = "tony.duong.102@gmail.com"
  user.name  = "Tony トニー"
  user.uid   = "LMUNn6BS4uP31Hfd3SBpno2TRtP2"
  user.providers = ["google.com"]
end

(1..100).each do |i|
  Tag.seed do |tag|
    tag.id = i
    tag.user_id = 1
    # `name` should be composed of lowercase letters, numbers, and underscores
    tag.name = Faker::Company.name.downcase.gsub(/\s/, "_")
    tag.description = Faker::Lorem.sentence(word_count: 10)
    tag.color = Faker::Color.hex_color
  end
end

(1..50).each do |i|
  BusinessCard.seed do |business_card|
    business_card.id = i
    business_card.user_id = 1
    business_card.last_name = Faker::Name.last_name
    business_card.first_name = Faker::Name.first_name
    business_card.company = Faker::Company.name
    business_card.email = Faker::Internet.email
    business_card.status = BusinessCard.statuses.keys.sample
    business_card.code = Faker::Code.unique.asin
    business_card.mobile_phone = Faker::PhoneNumber.cell_phone
    business_card.home_phone = Faker::PhoneNumber.phone_number
    business_card.fax = Faker::PhoneNumber.phone_number
    business_card.meeting_date = Faker::Date.between(from: 2.days.ago, to: Date.today)
    business_card.notes = Faker::Lorem.sentence(word_count: 10)
    business_card.tags = Tag.all.sample(3)
  end
end

# BusinessCard.all.each do |business_card|
#   business_card.front_image.attach(io: File.open(Rails.root.join('db', 'fixtures', 'files', 'front_image.png')), filename: 'front_image.png', content_type: 'image/png')
#   business_card.back_image.attach(io: File.open(Rails.root.join('db', 'fixtures', 'files', 'back_image.png')), filename: 'back_image.png', content_type: 'image/png')
# end
