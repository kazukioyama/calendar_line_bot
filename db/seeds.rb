# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

line_messaging_secret = Rails.application.credentials.line[:messaging_secret]
line_messaging_token = Rails.application.credentials.line[:messaging_token]

Admin.create(
  line_messaging_id: 1656359472,
  line_messaging_secret: line_messaging_secret,
  line_messaging_token: line_messaging_token
)
