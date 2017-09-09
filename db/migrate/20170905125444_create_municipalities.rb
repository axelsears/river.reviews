class CreateMunicipalities < ActiveRecord::Migration[5.1]
  def change
    create_table :municipalities do |t|
      t.string :name
      t.belongs_to :state, foreign_key: true
      t.string :zone
      t.decimal "latitude", precision: 10, scale: 6
      t.decimal "longitude", precision: 10, scale: 6
      t.timestamps
    end
  end
end
