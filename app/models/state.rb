class State < ApplicationRecord
  has_many :municipalities, dependent: :destroy
  has_many :waterways, through: :municipalities

  accepts_nested_attributes_for :municipalities
  accepts_nested_attributes_for :waterways

  require 'json'
  include HTTParty

  # def self.repair_children
  #   @states = State.all
  #   @states.each { |state|
  #     puts state.name
  #     names_with_multiple = state.municipalities.group(:name).having("count(name) > 1").count.keys
  #     zones_with_multiple = state.municipalities.group(:zone).having("count(zone) > 1").count.keys
  #     state.municipalities.where(zone: zones_with_multiple).map{|i|
  #       puts i.as_json
  #     }
  #     # municipalities = state.municipalities.where(zone: nil)
  #     # municipalities = state.municipalities.select(:name,:zone).group(:name,:zone).having("count(*) > 1")
  #     # municipalities.each { |municipality|
  #     #
  #     #   # matching = state.municipalities.where(name: municipality.name, zone: present?)
  #     #   puts municipality.as_json
  #     #   # puts matching.as_json
  #     #   # puts ' '
  #     #     # query = Geocoder.search([municipality.name, state.abbreviation].join(", ")).first
  #     #     # puts query.as_json
  #     #     # puts query.as_json
  #     #     # query.present? || next
  #     #     # municipality.zone = query.postal_code
  #     #     # puts municipality.zone
  #     #     # municipality.save #.update(name: query.city)
  #     # }
  #   }
  # end

  def self.seed_municipalities
      last_record = Municipality.order('created_at DESC').first.state['id'].to_i + 1
      # last_record = 1
      @states = State.where(:id => 22..23)
      # @states = State.all
      base_uri = "https://waterservices.usgs.gov/nwis/iv/?format=json&siteStatus=active&siteType=ST&stateCd="

      @states.each do |state|
        # next if state.id == 1
        # next if state.id == (1,2,3,4,5)
        puts "\n\n#{state.name}"
        municipalities = Array.new
        waterways = Array.new

        json = JSON.parse(HTTParty.get("#{base_uri}#{state.abbreviation.downcase}").body)['value']['timeSeries']

        json.uniq{|u| u['sourceInfo']['siteCode'][0]['value']}.map { |x|

          site_id = x['sourceInfo']['siteCode'][0]['value']
          latitude = x['sourceInfo']['geoLocation']['geogLocation']['latitude']
          longitude = x['sourceInfo']['geoLocation']['geogLocation']['longitude']

          name = nil
          zone = nil

          Geocoder.search("#{latitude},#{longitude}").each{ |q|
            name ||= q.city if name.nil?
            zone ||= q.postal_code if zone.nil?
          }

          if zone.nil? && name.nil?
            puts "Skipping #{site_id}"
            next
          end

          name ||= "#{zone}".to_region(:city => true) if name.nil?
          zone ||= "#{name}, #{state.abbreviation}".to_zip.first if zone.nil?

          municipality = state.municipalities.new({
              name: name,
              zone: zone
          })

          unless municipalities.any? {|matching| matching[:zone] == zone && matching[:name] == name }
            municipalities.push(municipality)
            municipality.save
          end

        }

      end

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
