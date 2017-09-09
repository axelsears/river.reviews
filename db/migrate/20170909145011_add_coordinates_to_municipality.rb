class AddCoordinatesToMunicipality < ActiveRecord::Migration[5.1]
  def change
    add_column :municipalities, :latitude, :decimal, {:precision=>10, :scale=>6}
    add_column :municipalities, :longitude, :decimal, {:precision=>10, :scale=>6}
  end
end
