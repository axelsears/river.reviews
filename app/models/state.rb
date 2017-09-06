class State < ApplicationRecord
  has_many :municipalities, dependent: :destroy
  has_many :waterways, through: :municipalities

  accepts_nested_attributes_for :municipalities
  accepts_nested_attributes_for :waterways

  require 'json'
  include HTTParty

  # def self.list_all
  #
  #   @states = State.all
  #   @states.each { |state|
  #
  #     uri = "https://waterservices.usgs.gov/nwis/iv/?format=json&siteStatus=active&siteType=ST&stateCd="+state.abbreviation.downcase
  #     municipalities = JSON.parse(HTTParty.get(uri).body)['value']['timeSeries']
  #     @municipalities = Array.new
  #
  #     municipalities.each { |m|
  #         municipality = state.municipalities.new
  #         latitude = m['sourceInfo']['geoLocation']['geogLocation']['latitude']
  #         longitude = m['sourceInfo']['geoLocation']['geogLocation']['longitude']
  #
  #         if @municipalities.any? {|matching| matching[:latitude] == latitude && matching[:longitude] == longitude }
  #           puts 'skipping'
  #           next
  #         end
  #
  #         query = Geocoder.search([latitude, longitude].join(",")).first
  #         query.present? || next
  #
  #         unless @municipalities.any? {|matching| matching[:zone] == query.postal_code}
  #           municipality.name = query.city
  #           municipality.zone = query.postal_code
  #           municipality.save
  #           @municipalities.push(municipality)
  #         end
  #       }
  #   }
  # end


end
