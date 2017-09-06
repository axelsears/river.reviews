class Municipality < ApplicationRecord
  belongs_to :state
  has_many :waterways, dependent: :destroy
end
