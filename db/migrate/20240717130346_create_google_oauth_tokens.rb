class CreateGoogleOauthTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :google_oauth_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :access_token, null: false
      t.string :refresh_token, null: false
      t.timestamps
    end
  end
end
