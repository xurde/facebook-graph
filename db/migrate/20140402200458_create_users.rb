class CreateUsers < ActiveRecord::Migration

  def change
    create_table :users do |t|
      t.integer :fb_id
      t.string :access_token
      t.string :username
      t.string :name
      t.string :first_name
      t.string :last_name
      t.string :link
      t.string :gender
      t.string :hometown
      t.string :location
      t.string :religion
      t.string :political
      t.integer :timezone
      t.string :locale

      t.timestamps
    end
  end

end
