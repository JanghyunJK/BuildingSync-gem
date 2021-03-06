# *******************************************************************************
# OpenStudio(R), Copyright (c) 2008-2019, Alliance for Sustainable Energy, LLC.
# BuildingSync(R), Copyright (c) 2015-2019, Alliance for Sustainable Energy, LLC.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# (1) Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# (2) Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# (3) Neither the name of the copyright holder nor the names of any contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission from the respective party.
#
# (4) Other than as required in clauses (1) and (2), distributions in any form
# of modifications or other derivative works may not use the "OpenStudio"
# trademark, "OS", "os", or any other confusingly similar designation without
# specific prior written permission from Alliance for Sustainable Energy, LLC.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER(S) AND ANY CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER(S), ANY CONTRIBUTORS, THE
# UNITED STATES GOVERNMENT, OR THE UNITED STATES DEPARTMENT OF ENERGY, NOR ANY OF
# THEIR EMPLOYEES, BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
# OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# *******************************************************************************
require_relative 'building'
module BuildingSync
  class Site < SpatialElement
    # initialize
    def initialize(build_element, ns)
      # code to initialize
      # an array that contains all the buildings
      @buildings = []
      @largest_building = nil
      @premises_notes = nil
      @all_set = false


      # parameter to read and write.
      @climate_zone = nil
      @climate_zone_ashrae = nil
      @climate_zone_ca_t24 = nil
      @weather_file_name = nil
      @weather_station_id = nil
      @city_name = nil
      @state_name = nil
      @latitude = nil
      @longitude = nil
      @street_address = nil
      @postal_code = nil


      # TM: just use the XML snippet to search for the buildings on the site
      read_xml(build_element, ns)
    end

    # adding a site to the facility
    def read_xml(build_element, ns)
      # first we check if the number of buildings is ok
      number_of_buildings = 0
      build_element.elements.each("#{ns}:Buildings/#{ns}:Building") do |buildings_element|
        number_of_buildings += 1
      end
      if number_of_buildings == 0
        OpenStudio.logFree(OpenStudio::Error, 'BuildingSync.Site.generate_baseline_osm', 'There is no building attached to this site in your BuildingSync file.')
        raise 'Error: There is no building attached to this site in your BuildingSync file.'
      elsif number_of_buildings > 1
        OpenStudio.logFree(OpenStudio::Error, 'BuildingSync.Site.generate_baseline_osm', "There is more than one (#{number_of_buildings}) building attached to this site in your BuildingSync file.")
        raise "Error: There is more than one (#{number_of_buildings}) building attached to this site in your BuildingSync file."
      end
      # check occupancy type at the site level
      @occupancy_type = read_occupancy_type(build_element, nil, ns)
      # check floor areas at the site level
      @total_floor_area = read_floor_areas(build_element, nil, ns)
      # read in the ASHRAE climate zone
      read_climate_zone(build_element, ns)
      # read in the weather station name
      read_weather_file_name(build_element, ns)
      # read city and state name
      read_city_and_state_name(build_element, ns)
      # read latitude and longitude
      read_latitude_and_longitude(build_element, ns)
      # read site address
      read_site_other_details(build_element, ns)
      # code to create a building
      build_element.elements.each("#{ns}:Buildings/#{ns}:Building") do |buildings_element|
        @buildings.push(Building.new(buildings_element, @occupancy_type, @total_floor_area, ns))
      end
    end

    def set_all
      if !@all_set
        @all_set = true
        @buildings.each(&:set_all)
      end
    end

    def read_climate_zone(build_element, ns)
      if build_element.elements["#{ns}:ClimateZoneType/#{ns}:ASHRAE"]
        @climate_zone_ashrae = build_element.elements["#{ns}:ClimateZoneType/#{ns}:ASHRAE/#{ns}:ClimateZone"].text
      else
        @climate_zone_ashrae = nil
      end
      if build_element.elements["#{ns}:ClimateZoneType/#{ns}:CaliforniaTitle24"]
        @climate_zone_ca_t24 = build_element.elements["#{ns}:ClimateZoneType/#{ns}:CaliforniaTitle24/#{ns}:ClimateZone"].text
      else
        @climate_zone_ca_t24 = nil
      end
      if @climate_zone_ca_t24.nil? && @climate_zone_ashrae.nil?
        OpenStudio.logFree(OpenStudio::Warn, 'BuildingSync.Site.read_climate_zone', 'Could not find a climate zone in the BuildingSync file.')
      end
    end

    def read_weather_file_name(build_element, ns)
      if build_element.elements["#{ns}:WeatherStationName"]
        @weather_file_name = build_element.elements["#{ns}:WeatherStationName"].text
      else
        @weather_file_name = nil
      end
      if build_element.elements["#{ns}:WeatherDataStationID"]
        @weather_station_id = build_element.elements["#{ns}:WeatherDataStationID"].text
      else
        @weather_station_id = nil
      end
    end

    def read_city_and_state_name(build_element, ns)
      if build_element.elements["#{ns}:Address/#{ns}:City"]
        @city_name = build_element.elements["#{ns}:Address/#{ns}:City"].text
      else
        @city_name = nil
      end
      if build_element.elements["#{ns}:Address/#{ns}:State"]
        @state_name = build_element.elements["#{ns}:Address/#{ns}:State"].text
      else
        @state_name = nil
      end
    end

    def read_site_other_details(build_element, ns)
      if build_element.elements["#{ns}:Address/#{ns}:StreetAddressDetail/#{ns}:Simplified/#{ns}:StreetAddress"]
        @street_address = build_element.elements["#{ns}:Address/#{ns}:StreetAddressDetail/#{ns}:Simplified/#{ns}:StreetAddress"].text
      else
        @street_address = nil
      end

      if build_element.elements["#{ns}:Address/#{ns}:PostalCode"]
        @postal_code = build_element.elements["#{ns}:Address/#{ns}:PostalCode"].text.to_i
      else
        @postal_code = nil
      end

      if build_element.elements["#{ns}:PremisesNotes"]
        @premises_notes = build_element.elements["#{ns}:PremisesNotes"].text
      else
        @premises_notes = nil
      end
    end

    def read_latitude_and_longitude(build_element, ns)
      if build_element.elements["#{ns}:Latitude"]
        @latitude = build_element.elements["#{ns}:Latitude"].text
      else
        @latitude = nil
      end
      if build_element.elements["#{ns}:Longitude"]
        @longitude = build_element.elements["#{ns}:Longitude"].text
      else
        @longitude = nil
      end
    end

    def build_zone_hash
      return get_largest_building.build_zone_hash
    end

    def get_model
      return get_largest_building.get_model
    end

    def get_space_types
      return get_largest_building.get_space_types
    end

    def get_peak_occupancy
      return get_largest_building.get_peak_occupancy
    end

    def get_floor_area
      return get_largest_building.get_floor_area
    end

    def get_building_sections
      return get_largest_building.building_sections
    end

    def determine_open_studio_standard(standard_to_be_used)
      set_all
      return get_largest_building.determine_open_studio_standard(standard_to_be_used)
    end

    def determine_open_studio_system_standard
      set_all
      return Standard.build(get_building_template)
    end

    def get_building_template
      return get_largest_building.get_building_template
    end

    def get_space_types_from_hash(id)
      return get_largest_building.build_space_type_hash[id]
    end

    def get_system_type
      return get_largest_building.get_system_type
    end

    def get_building_type
      if @bldg_type.nil?
        return get_largest_building.get_building_type
      else
        return @bldg_type
      end
    end

    def get_climate_zone
      return @climate_zone
    end

    def get_building_objects
      return @buildings
    end

    def get_largest_building
      if !@largest_building.nil?
        return @largest_building
      else
        if @buildings.count == 1
          return @buildings[0]
        elsif @buildings.count > 1
          OpenStudio.logFree(OpenStudio::Error, 'BuildingSync.Site.generate_baseline_osm', "There are more than one (#{@buildings.count}) buildings attached to this site in your BuildingSync file.")
          @largest_building = nil
          largest_floor_area = -Float::INFINITY
          @buildings.each do |building|
            if largest_floor_area < building.total_floor_area
              largest_floor_area = building.total_floor_area
              @largest_building = building
            end
          end
          OpenStudio.logFree(OpenStudio::Info, 'BuildingSync.Site.generate_baseline_osm', "The building (#{@largest_building.name}) with the largest floor area (#{largest_floor_area}) was selected.")
          puts "BuildingSync.Site.generate_baseline_osm: The building (#{@largest_building.name}) with the largest floor area (#{largest_floor_area}) m^2 was selected."
          return @largest_building
        end
      end
    end

    def generate_baseline_osm(epw_file_path, standard_to_be_used, ddy_file = nil)
      set_all
      building = get_largest_building
      @climate_zone = @climate_zone_ashrae
      # for now we use the california climate zone if it is available
      @climate_zone = @climate_zone_ca_t24 if !@climate_zone_ca_t24.nil? && standard_to_be_used == CA_TITLE24
      building.set_weather_and_climate_zone(@climate_zone, epw_file_path, standard_to_be_used, @latitude, @longitude, ddy_file, @weather_file_name, @weather_station_id, @state_name, @city_name)
      building.generate_baseline_osm(standard_to_be_used)
    end

    def write_osm(dir)
      building = get_largest_building
      building.write_osm(dir)
      scenario_types = {}
      scenario_types['system_type'] = get_system_type
      scenario_types['bldg_type'] = get_building_type
      scenario_types['template'] = get_building_template
      return scenario_types
    end

    def write_parameters_to_xml(ns, site)
      site.elements["#{ns}:ClimateZoneType/#{ns}:ASHRAE/#{ns}:ClimateZone"].text = @climate_zone_ashrae if !@climate_zone_ashrae.nil?
      site.elements["#{ns}:ClimateZoneType/#{ns}:CaliforniaTitle24/#{ns}:ClimateZone"].text = @climate_zone_ca_t24 if !@climate_zone_ca_t24.nil?
      site.elements["#{ns}:WeatherStationName"].text = @weather_file_name if !@weather_file_name.nil?
      site.elements["#{ns}:WeatherDataStationID"].text = @weather_station_id if !@weather_station_id.nil?
      site.elements["#{ns}:Address/#{ns}:City"].text = @city_name if !@city_name.nil?
      site.elements["#{ns}:Address/#{ns}:State"].text = @state_name if !@state_name.nil?
      site.elements["#{ns}:Address/#{ns}:StreetAddressDetail/#{ns}:Simplified/#{ns}:StreetAddress"].text = @street_address if !@street_address.nil?
      site.elements["#{ns}:Address/#{ns}:PostalCode"].text = @postal_code if !@postal_code.nil?
      site.elements["#{ns}:Latitude"].text = @latitude if !@latitude.nil?
      site.elements["#{ns}:Longitude"].text = @longitude if !@longitude.nil?

      write_parameters_to_xml_for_spatial_element(ns, site)

      site.elements.each("#{ns}:Buildings/#{ns}:Building") do |buildings_element|
        @buildings[0].write_parameters_to_xml(ns, buildings_element)
      end
    end
  end
end
