class CreateAdmins < ActiveRecord::Migration[6.0]
  def change
    create_table :admins do |t|
      t.integer "line_messaging_id", null: false # Messaging APIの「チャネルID」
      t.string "line_messaging_secret", null: false # Messaging APIの「チャネルシークレット」
      t.string "line_messaging_token", null: false # Messaging APIの「チャネルアクセストークン」
      t.integer "line_login_id", null: false # LINE Loginの「チャネルID」
      t.string "line_login_secret", null: false # LINE Loginの「チャネルシークレット」
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end
  end
end
