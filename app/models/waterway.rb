class Waterway < ApplicationRecord

  require 'json'
  # require 'ostruct'
  include HTTParty

  belongs_to :municipality
  belongs_to :state

  reverse_geocoded_by :latitude, :longitude
  after_validation :reverse_geocode  # auto-fetch address

  # def self.all(state)
  #   # query = Geocoder.search("44.981667,-93.27833").first
  #   # query.postal_code
  #   # query.city
  #   # query.state
  #   # query.
  #   base_uri = "https://waterservices.usgs.gov/nwis/iv/?format=json&siteStatus=active&siteType=ST&stateCd="
  #   waterways = JSON.parse(HTTParty.get(base_uri+state).body)['value']['timeSeries']
  #
  #   @state = State.find_by_abbreviation(state.upcase)
  #
  #   # @waterways = Array.new
  #   # waterways.each{ |w|
  #   #
  #   #   latitude = w['sourceInfo']['geoLocation']['geogLocation']['latitude']
  #   #   longitude = w['sourceInfo']['geoLocation']['geogLocation']['longitude']
  #   #   query = Geocoder.search([latitude, longitude].join(",")).first
  #   #
  #   #   municipality = @state.municipalities
  #   #   municipality.create!
  #   #   municipality.name = query.city
  #   #   municipality.zone = query.postal_code
  #   #
  #   #   # municipality.save!
  #   #
  #   #   waterway = municipality.waterways.create
  #   #   waterway.name = w['sourceInfo']['siteName']
  #   #   waterway.site_id = w['sourceInfo']['siteCode'][0]['value']
  #   #   waterway.latitude = w['sourceInfo']['geoLocation']['geogLocation']['latitude']
  #   #   waterway.longitude = w['sourceInfo']['geoLocation']['geogLocation']['longitude']
  #   #
  #   #
  #   #
  #   #   @waterways.push(waterway)
  #   # }
  #   # @waterways.uniq!{|obj| obj.site_id }
  # end

end
