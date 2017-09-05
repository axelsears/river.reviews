class CreateWaterways < ActiveRecord::Migration[5.1]
  def change
    create_table :waterways do |t|
      t.string :name
      t.string :site_id, unique: true
      t.belongs_to :municipality, foreign_key: true
      t.decimal :latitude
      t.decimal :longitude

      t.timestamps
    end
  end
end
