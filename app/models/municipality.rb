class Municipality < ApplicationRecord
  belongs_to :state
  has_many :waterways, dependent: :destroy

  # reverse_geocoded_by :latitude, :longitude
  # after_validation :reverse_geocode  # auto-fetch address
end
