class State < ApplicationRecord
  has_many :municipalities, dependent: :destroy
  has_many :waterways, through: :municipalities

  accepts_nested_attributes_for :municipalities
  accepts_nested_attributes_for :waterways

  require 'json'
  include HTTParty

  def self.repair_children
    @states = State.all
    @states.each { |state|
      puts state.name
      names_with_multiple = state.municipalities.group(:name).having("count(name) > 1").count.keys
      zones_with_multiple = state.municipalities.group(:zone).having("count(zone) > 1").count.keys
      state.municipalities.where(zone: zones_with_multiple).map{|i|
        puts i.as_json
      }
      # municipalities = state.municipalities.where(zone: nil)
      # municipalities = state.municipalities.select(:name,:zone).group(:name,:zone).having("count(*) > 1")
      # municipalities.each { |municipality|
      #
      #   # matching = state.municipalities.where(name: municipality.name, zone: present?)
      #   puts municipality.as_json
      #   # puts matching.as_json
      #   # puts ' '
      #     # query = Geocoder.search([municipality.name, state.abbreviation].join(", ")).first
      #     # puts query.as_json
      #     # puts query.as_json
      #     # query.present? || next
      #     # municipality.zone = query.postal_code
      #     # puts municipality.zone
      #     # municipality.save #.update(name: query.city)
      # }
    }
  end

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
