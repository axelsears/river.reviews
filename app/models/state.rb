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

  def self.final_attempt
    base_uri = 'https://waterservices.usgs.gov/nwis/iv/?format=json&parameterCd=00060,00065,00055,00004,00061&siteStatus=active&sites='

    File.readlines('skipped_sites.txt').each do |site_id|
      next unless Waterway.where(site_id: site_id.strip).count == 0

      json = JSON.parse(HTTParty.get("#{base_uri}#{site_id.strip}").body)['value']['timeSeries']
      json.map do |x|
        site_name = x['sourceInfo']['siteName']
        latitude = x['sourceInfo']['geoLocation']['geogLocation']['latitude']
        longitude = x['sourceInfo']['geoLocation']['geogLocation']['longitude']

        name_formatted = site_name.strip.split.last(3).join(" ").remove('at ','NR ', 'NEAR ', 'AT ', 'near ', 'nr ', ' (CORPS)', '(lower) ', ',', '.').sub("FLA", "FL").sub("FLMINGO", "Flamingo")
        state_abbreviation = nil
        Geocoder.search(name_formatted).each do |query|
          # puts query.as_json
          state_abbreviation ||= query.state_code
          # next unless zone.nil?
          # zone ||= query.postal_code
        end
        zone = nil
        city = nil
        # name = site_name

        Geocoder.search(name_formatted.sub(" #{state_abbreviation}",", #{state_abbreviation}")).each do |query|
          zone ||= query.postal_code
          city ||= query.city
        end
        zone = name_formatted.sub(" #{state_abbreviation}",", #{state_abbreviation}").to_zip if zone.nil?

        state = State.find_by_abbreviation(state_abbreviation)

        if state.nil?
          open('skippedsites2.txt', 'a') { |f|
            f.puts "Skipping #{site_id.strip}"
          }
        end
        next if state.nil?
        municipality = state.municipalities.find_by_zone(zone.first)
        # puts municipality.as_json
        unless municipality.present?
          municipality = state.municipalities.new
          municipality.zone = zone.first
          municipality.name = city || zone.first.to_region(city: true)
          # puts zone
          # municipality.latitude = zone.first.to_latlon.split(", ").first
          # municipality.longitude = zone.first.to_latlon.split(", ").last
          # municipality.save
          # puts zone.to_region(city: true)
        end
        # puts municipality.present?
        # next

        waterway = municipality.waterways.new
        waterway.site_id = site_id.strip
        waterway.name = site_name
        waterway.latitude = latitude
        waterway.longitude = longitude
        waterway.save


        # municipality = state.municipalities.where(name: city) if municipality.nil?
        # puts municipality.count
        # puts zone #.nil?
        # puts city
        # site_name = x['sourceInfo']['siteName']
      end
      # site_name = json['sourceInfo']['siteName']
      # latitude = json['sourceInfo']['geoLocation']['geogLocation']['latitude']
      # longitude = json['sourceInfo']['geoLocation']['geogLocation']['longitude']

      # puts "#{site_name}"

    end

  end

  def self.troublemakers
    base_uri = 'https://waterservices.usgs.gov/nwis/iv/?format=json&parameterCd=00060,00065,00055,00004,00061&siteStatus=active&sites='
    File.readlines('skipped_sites.txt').each do |site_id|
      # site_id = site_id.split('\n').first.to_s
      site_id = site_id.strip
      puts site_id
      next unless Waterway.where(site_id: site_id).count == 0
      json = JSON.parse(HTTParty.get("#{base_uri}#{site_id}").body)['value']['timeSeries']
      json.map{|x|
        site_name = x['sourceInfo']['siteName']
        latitude = x['sourceInfo']['geoLocation']['geogLocation']['latitude']
        longitude = x['sourceInfo']['geoLocation']['geogLocation']['longitude']
        next if site_name.include?("ONTARIO")
        next if site_name.include?("INTERNATIONAL BOUNDARY")
        next if site_name.include?("Dam Lower Pool")
        next if site_name.include?("Damsite Reading")

        name_formatted = site_name.split.last(3).join(" ").remove('at ','NR ', 'NEAR ', 'AT ', 'near ', 'nr ', ' (CORPS)', '(lower) ', ',', '.').sub("FLA", "FL").sub("FLMINGO", "Flamingo").sub("Atchafalaya Bay", "Atchafalaya Bay LA")
        state_abbreviation = nil
        Geocoder.search(name_formatted).each do |query|
          # puts query.as_json
          state_abbreviation ||= query.state_code
          # next unless zone.nil?
          # zone ||= query.postal_code
        end

        puts

        name_formatted += " #{state_abbreviation}" unless "#{name_formatted.split.last}" == "#{state_abbreviation}"
        zone = nil
        city = nil
        Geocoder.search(name_formatted).each do |query|
          # puts query.as_json
          # state_abbreviation ||= query.state_code
          # next unless zone.nil?
          zone ||= query.postal_code
          city ||= query.city
          # puts query.city
          # puts query.postal_code
        end

        city ||= name_formatted.sub("#{name_formatted.split.last}", "")

        # puts city

        state = State.find_by_abbreviation(state_abbreviation)
        if zone.nil?
          zone ||= "#{city}, #{state_abbreviation}".to_zip unless city.nil?
        end

        municipality = state.municipalities.find_by_zone(zone)
        unless municipality.nil?
          waterway = municipality.waterways.new
          waterway.name = site_name
          waterway.site_id = site_id
          waterway.latitude = latitude
          waterway.longitude = longitude
          waterway.save
        end
        # puts zone
        sleep 1
      }
    end
  end

  def self.skipped_sites
    sites = Array.new
    base_uri = 'https://waterservices.usgs.gov/nwis/iv/?format=json&parameterCd=00060,00065,00055,00004,00061&siteStatus=active&sites='
    File.readlines('myfile.out').each do |line|

      site_id = line.split(' |').first
      next unless Waterway.where(site_id: site_id).count == 0
      # puts sites.as_json

      open('skipped_sites.txt', 'a') { |f|
        f.puts site_id
      }

        json = JSON.parse(HTTParty.get("#{base_uri}#{site_id}").body)['value']['timeSeries']
        json.each do |x|
          next if sites.any?{|s| s == site_id} || x['sourceInfo']['geoLocation']['geogLocation']['latitude'] == 0.0
          sites.push(x['sourceInfo']['siteCode'][0]['value'])



          # site_id = x['sourceInfo']['siteCode'][0]['value']
          site_name = x['sourceInfo']['siteName']
          latitude = x['sourceInfo']['geoLocation']['geogLocation']['latitude']
          longitude = x['sourceInfo']['geoLocation']['geogLocation']['longitude']

          state_abbreviation = nil
          zone = nil
          Geocoder.search([latitude,longitude]).each do |query|
            state_abbreviation ||= query.state
            next unless zone.nil?
            zone ||= query.postal_code
          end
          # puts zone
          municipality = Municipality.where(zone: zone)
          next if municipality.count == 0
          puts "#{municipality.first.name}\n#{site_name}\n\n\n"
          waterway = municipality.first.waterways.new
          waterway.name = site_name
          waterway.site_id = site_id
          waterway.latitude = latitude
          waterway.longitude = longitude

          waterway.save
          sleep 1
          # puts state_abbreviation
          # state = State.find_by_abbreviation(state_abbreviation)
          # puts state.municipalities.where(zone: zone).count
          # if zone.nil?
          #   municipality = state.municipalities.near([latitude,longitude])
          #   next if municipality.nil? || municipality.first.blank?
          #   municipality = municipality.first
          #   puts "#{site_name}\n had no zone"
          # else
          #   municipality = state.municipalities.find_by_zone(zone)
          #   puts "#{site_name}\n had a zone #{zone}"
          # end
          #
          #
          # next if municipality.nil?
          #
          #
          # puts municipality.as_json
          # waterway = municipality.waterways.new
          # waterway.name = site_name
          # waterway.latitude = latitude
          # waterway.longitude = longitude
          # waterway.site_id = site_id
          #
          # puts waterway.as_json
          # state = State.find_by_a?bbreviation(state_abbreviation.upcase)
          # puts "\n\n#{site_id} #{site_name}"
          # state.municipalities.near([latitude,longitude]).as_json

        end

    end
    puts sites.count

  end

  def self.update_municipalities
    @states = State.all
    @states.each do |state|
      municipalities = state.municipalities.where(latitude:nil)
      next if municipalities.count == 0
      municipalities.each do |municipality|
        Geocoder.search(municipality.zone).each{|x|
          next unless municipality.latitude.nil?
          municipality.latitude ||= x.latitude
          municipality.longitude ||= x.longitude
        }
        if municipality.latitude.nil?
          open('myfile.out', 'a') { |f|
            f.puts "Skipping #{municipality.name}, #{state.abbreviation}, #{municipality.zone}\n"
          }
        else
          municipality.save
        end
      end
    end
  end

  def self.repair_municipalities
    @states = State.all
    @states.each do |state|
      municipalities = state.municipalities.where(name:nil)
      municipalities.each do |municipality|

        Geocoder.search(municipality.zone).each{|m|
          municipality.name ||= m.city if municipality.name.nil?
        }

        # puts municipality.as_json unless municipality.name.nil?
        # coords = nil
        # Geocoder.search("#{municipality.name}, #{state.abbreviation}").each{|m|
        #   # municipality.zone ||= m.postal_code
        #   # temp_name ||= m.address
        #   coords ||= m.coordinates if coords.nil?
        #   # puts "#{m.coordinates.to_s.to_region(:city => true)}\n"
        # }
        #
        # Geocoder.search(coords).each{|m|
        #   municipality.zone ||= m.postal_code if municipality.zone.nil?
        # }

        municipality.save

        open('myfile.out', 'w') { |f|
          f.puts "#{Municipality.where(name: nil).count}"
          f.puts " "
        }

      end
    end
  end

  def self.seed_municipalities
      # last_record = Municipality.order('created_at DESC').first.state['id'].to_i + 1
      # last_record = 1
      # @states = State.where(:id => 22..23)
      @states = State.all
      base_uri = "https://waterservices.usgs.gov/nwis/iv/?format=json&siteStatus=active&siteType=ST&stateCd="

      @states.each do |state|
        # next if state.id == 1
        # next if state.id == (1,2,3,4,5)
        puts "\n\n#{state.name}"
        municipalities = Array.new
        waterways = Array.new

        json = JSON.parse(HTTParty.get("#{base_uri}#{state.abbreviation.downcase}").body)['value']['timeSeries']

        json.uniq{|u| u['sourceInfo']['siteCode'][0]['value']}.each { |x|

          next unless Waterway.find_by_site_id(x['sourceInfo']['siteCode'][0]['value']).nil?

          site_id = x['sourceInfo']['siteCode'][0]['value']
          site_name = x['sourceInfo']['siteName']
          latitude = x['sourceInfo']['geoLocation']['geogLocation']['latitude']
          longitude = x['sourceInfo']['geoLocation']['geogLocation']['longitude']

          name = nil
          zone = nil

          Geocoder.search("#{latitude},#{longitude}").each{ |q|
            name ||= q.city if name.nil?
            zone ||= q.postal_code if zone.nil?
          }

          if zone.nil? && name.nil?
            open('myfile.out', 'a') { |f|
              f.puts "#{site_id} | Skipping "
            }
            next
          end

          name ||= "#{zone}".to_region(:city => true) if name.nil?
          zone ||= "#{name}, #{state.abbreviation}".to_zip.first if zone.nil?

          municipality = state.municipalities.where(zone: zone, name: name).first
          # municipality = state.municipalities.find_all_by_name_and_zone(name, zone)
          # puts municipality.inspect
          if municipality.nil?
            open('myfile.out', 'a') { |f|
              f.puts "#{site_id} | No match for #{site_name}\n#{municipality.as_json}"
            }
            next
          else
            waterway = municipality.waterways.new({
                site_id: site_id,
                name: site_name,
                latitude: latitude,
                longitude: longitude
            })
            # waterway.site_id = site_id
            # waterway.name = site_name
            # waterway.latitude = latitude
            # waterway.longitude = longitude
            # next
            waterway.save!
          end


          # unless municipalities.any? {|matching| matching[:zone] == zone && matching[:name] == name }
          #   municipalities.push(municipality)
          #   municipality.save
          # end

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
