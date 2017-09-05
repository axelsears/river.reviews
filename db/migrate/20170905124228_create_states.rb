class CreateStates < ActiveRecord::Migration[5.1]
  def change
    create_table :states do |t|
      t.string :abbreviation, limit: 2, unique: true
      t.string :name, limit: 200

      t.timestamps
    end
  end
end
