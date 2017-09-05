class CreateMunicipalities < ActiveRecord::Migration[5.1]
  def change
    create_table :municipalities do |t|
      t.string :name
      t.belongs_to :state, foreign_key: true
      t.string :zone, unique: true

      t.timestamps
    end
  end
end
