class CreateWaterways < ActiveRecord::Migration[5.1]
  def change
    create_table :waterways do |t|
      t.string :name
      t.string :site_id, unique: true
      t.belongs_to :municipality, foreign_key: true
      t.decimal "latitude", precision: 10, scale: 6
      t.decimal "longitude", precision: 10, scale: 6
      t.timestamps
    end
  end
end
