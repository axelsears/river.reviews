class State < ApplicationRecord
  has_many :municipalities
  has_many :waterways, through: :municipalities

  accepts_nested_attributes_for :municipalities
  accepts_nested_attributes_for :waterways

  require 'json'
  include HTTParty



  def self.list_single(state)
    abbreviation = state.abbreviation.downcase
    # JSON.parse(HTTParty.get(base_uri+abbreviation).body) #['value']['timeSeries']
    # json = HTTParty.get(base_uri+state['abbreviation'].downcase)
    # waterways = JSON.parse(HTTParty.get(base_uri+state['abbreviation'].downcase).body)['value']['timeSeries']
    # state.name
    # waterways
  end


  def self.list_all

    @states = State.find(1,2)
    @states.each { |state|
      # self.list_single(state)
      uri = "https://waterservices.usgs.gov/nwis/iv/?format=json&siteStatus=active&siteType=ST&stateCd="+state.abbreviation.downcase
      municipalities = JSON.parse(HTTParty.get(uri).body)['value']['timeSeries']
      @municipalities = Array.new
      municipalities.each { |m|
          # puts state.id
          municipality = state.municipalities.new
          latitude = m['sourceInfo']['geoLocation']['geogLocation']['latitude']
          longitude = m['sourceInfo']['geoLocation']['geogLocation']['longitude']

          query = Geocoder.search([latitude, longitude].join(",")).first
          municipality.name = query.city
          municipality.zone = query.postal_code
          municipality.save
          # @municipalities.push(municipality.to_json)
          # municipality
          # puts
          # query = Geocoder.search([latitude, longitude].join(",")).first
          # municipality.zone = query.postal_code
          # municipality.name = query.city
          # # @municipalities.push(municipality)
          # municipality.save!
          # site_id = w['sourceInfo']['siteCode'][0]['value']
      }

      # @municipalities.each { |coordinates|
      #   query = Geocoder.search([latitude, longitude].join(",")).first
      #   puts query.postal_code
      #   sleep 1
      # }
      # @municipalities.uniq!{|obj| obj.zone }
    }
  end


end
