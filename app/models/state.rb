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
      @states = State.where(:id => last_record..51)
      base_uri = "https://waterservices.usgs.gov/nwis/iv/?format=json&siteStatus=active&siteType=ST&stateCd="

      @states.each do |state|
        # next if state.id == 1
        # next if state.id == (1,2,3,4,5)
        puts state.name
        # @municipalities = state.municipalities
        municipalities = Array.new
        waterways = Array.new

        json = JSON.parse(HTTParty.get("#{base_uri}#{state.abbreviation.downcase}").body)['value']['timeSeries']

        json.map { |x|

          latitude = x['sourceInfo']['geoLocation']['geogLocation']['latitude']
          longitude = x['sourceInfo']['geoLocation']['geogLocation']['longitude']

          zone = [latitude,longitude].to_zip
          if zone.nil?
            Geocoder.search("#{latitude},#{longitude}").each{|q| zone ||= q.postal_code }
          end

          if zone.nil?
            Geocoder.search("#{latitude},#{longitude}").each{|q| name ||= q.city }
            zone = "#{name}, #{state}".to_zip.first unless name.nil?
          end

          if zone.nil?
             Geocoder.search("#{latitude},#{longitude}").each{|q| name ||= q.address }
             zone = "#{name}".to_zip.first unless name.nil?
          end

          if zone.nil?
             Geocoder.search("#{latitude},#{longitude}").each{|q| name ||= q.name }
             zone = "#{name}".to_zip.first unless name.nil?
           else
             name ||= "#{zone}".to_region(:city => true)
             if name.nil?
               Geocoder.search(zone).each{|q| name ||= q.city }
             ends
          end





          # next if query.blank?
          #
          #
          #
          #
          #
          # if query.postal_code.blank?
          #   puts query.inspect
          #   postal_code = [x['sourceInfo']['geoLocation']['geogLocation']['latitude'], x['sourceInfo']['geoLocation']['geogLocation']['longitude']].to_zip
          #   postal_code ||= "#{query.address}".to_zip.first unless query.address.nil?
          #   postal_code ||= "#{query.city}, #{state.name}".to_zip.first unless query.city.nil?
          #   postal_code ||= "#{query.name}".to_zip.first unless query.name.nil?
          #   postal_code ||= "#{query.name}, #{state.name}".to_zip.first unless query.name.nil?
          # else
          #   postal_code = query.postal_code
          # end
          #
          # if query.city.blank?
          #   name = "#{query.postal_code}".to_region(:city => true)
          # else
          #   name = query.city
          # end

          # postal_code ||= [x['sourceInfo']['geoLocation']['geogLocation']['latitude'], x['sourceInfo']['geoLocation']['geogLocation']['longitude']].to_zip.first

          # name = query.city unless query.city.blank?
          # name ||= "#{query.postal_code}".to_region(:city => true) #=> "Brooklyn"

          # next if state.municipalities.find_by_zone(postal_code).present?
          next if municipalities.map{|m| m.zone}.include? zone
          municipality = state.municipalities.new({
            name: name,
            zone: zone
          })

          if municipality.zone.blank? && municipality.name.blank?
            next
            open('myfile.out', 'a') { |f|
              f.puts "-----     Skipping     -----"
              f.puts "#{x['sourceInfo']['siteName']}"
              f.puts "#{latitude},#{longitude}"
              f.puts "#{x['sourceInfo']['siteCode'][0]['value']}"
              f.puts "-----                  -----"
              f.puts " "
            }
          elsif municipality.zone.blank?
            open('myfile.out', 'a') { |f|
              f.puts "-----     no zone     -----"
              f.puts "#{municipality.name}"
              f.puts "#{x['sourceInfo']['siteName']}"
              f.puts "#{latitude},#{longitude}"
              f.puts "#{x['sourceInfo']['siteCode'][0]['value']}"
              f.puts "-----                 -----"
              f.puts " "
            }
          elsif municipality.name.blank?
            open('myfile.out', 'a') { |f|
              f.puts "-----     no name     -----"
              f.puts "#{municipality.zone}"
              f.puts "#{x['sourceInfo']['siteName']}"
              f.puts "#{latitude},#{longitude}"
              f.puts "#{x['sourceInfo']['siteCode'][0]['value']}"
              f.puts "-----                 -----"
              f.puts " "
            }
          else
            puts [zone,name].join("     |     ")
            # puts municipality.as_json
          end
          municipalities.push(municipality)

          # sleep 1
        # municipalities.uniq!{|obj| obj.zone }  #
          # if municipality.zone.blank?
          #   puts "#{query.name} has no zone"
          # else
          #   puts municipality.as_json
          # end
          #
          # waterway = Waterway.new ({
          #   latitude: x['sourceInfo']['geoLocation']['geogLocation']['latitude'],
          #   longitude: x['sourceInfo']['geoLocation']['geogLocation']['longitude'],
          #   name: x['sourceInfo']['siteName'],
          #   site_id: x['sourceInfo']['siteCode'][0]['value']
          # })
          #
          # waterways.push(waterway)

          # query = Geocoder.search("#{waterway['latitude']},#{waterway['longitude']}").first
          # puts query.name
          # query.present? || next

          # puts waterway.as_json
        }

        # municipalities.each{ |m|
        #   m.save
        # }


        # waterways = waterways.uniq!{|obj| obj.site_id }

        # waterways.map { |waterway|
          # query = Geocoder.search("#{waterway['latitude']},#{waterway['longitude']}").first
          # if query.postal_code.blank?
          #   puts "#{query.name} has no zip!"
          # end
          # sleep 1
          # municipality = @municipalities.new ({
          #     name: query.name,
          #     zone: query.postal_code
          # })
          #
          # municipalities.push(municipality)

        # }

        # municipalities = municipalities.uniq!{|obj| obj.name }

        # puts municipalities.as_json

        sleep 2
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
