class ChangeTableCharset < ActiveRecord::Migration[6.0]
  def change
    ActiveRecord::Base.connection.tables.each{|table|
      sql = "ALTER TABLE #{table} CONVERT TO CHARACTER SET utf8mb4"
      ActiveRecord::Base.connection.execute(sql)
    }
  end
end
