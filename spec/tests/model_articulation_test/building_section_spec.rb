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

RSpec.describe 'BuildingSpec' do
  it 'Should generate meaningful error when passing empty XML data' do
    begin
      generate_baseline('building_151_Blank', nil, nil, 'auc')
    rescue StandardError => e
      puts "expected error message:Building type '' is nil but got: #{e.message} " if !e.message.include?("Building type '' is nil")
      expect(e.message.include?("Building type '' is nil")).to be true
    end
  end

  it 'Should return occupancy_type ' do
    building_section = get_building_section_from_file('building_151_level1.xml', ASHRAE90_1)
    expected_value = 'Retail'
    puts "expected occupancy_type : #{expected_value} but got: #{building_section.occupancy_type} " if building_section.occupancy_type != expected_value
    expect(building_section.occupancy_type == expected_value).to be true
  end

  it 'Should return typical_occupant_usage_value_hours ' do
    building_section = get_building_section_from_file('building_151_level1.xml', ASHRAE90_1)
    expected_value = '40.0'
    puts "expected typical_occupant_usage_value_hours : #{expected_value} but got: #{building_section.typical_occupant_usage_value_hours} " if building_section.typical_occupant_usage_value_hours != expected_value
    expect(building_section.typical_occupant_usage_value_hours == expected_value).to be true
  end

  it 'Should return typical_occupant_usage_value_weeks ' do
    building_section = get_building_section_from_file('building_151_level1.xml', ASHRAE90_1)
    expected_value = '50.0'
    puts "expected typical_occupant_usage_value_weeks : #{expected_value} but got: #{building_section.typical_occupant_usage_value_weeks} " if building_section.typical_occupant_usage_value_weeks != expected_value
    expect(building_section.typical_occupant_usage_value_weeks == expected_value).to be true
  end

  def get_building_section_from_file(xml_file_name, standard_to_be_used)
    xml_file_path = File.expand_path("../../files/#{xml_file_name}", File.dirname(__FILE__))
    File.open(xml_file_path, 'r') do |file|
      doc = REXML::Document.new(file)
      ns = 'auc'
      doc.elements.each("/#{ns}:BuildingSync/#{ns}:Facilities/#{ns}:Facility/#{ns}:Sites/#{ns}:Site/#{ns}:Buildings/#{ns}:Building/#{ns}:Sections/#{ns}:Section") do |building_section|
        return BuildingSync::BuildingSection.new(building_section, 'Office', '20000', ns)
      end
    end
  end

  def generate_baseline(file_name, occupancy_type, total_floor_area, ns)
    sub_sections = []
    xml_path = File.expand_path("../../files/#{file_name}.xml", File.dirname(__FILE__))
    expect(File.exist?(xml_path)).to be true

    doc = create_xml_file_object(xml_path)
    building_xml = create_building_object(doc, ns)

    building_xml.elements.each("#{ns}:Sections/#{ns}:Section") do |building_element|
      sub_sections.push(BuildingSync::BuildingSection.new(building_element, occupancy_type, total_floor_area, ns))
    end
    return sub_sections
  end

  def create_building_object(doc, ns)
    buildings = []
    doc.elements.each("/#{ns}:BuildingSync/#{ns}:Facilities/#{ns}:Facility/#{ns}:Sites/#{ns}:Site/#{ns}:Buildings/#{ns}:Building") do |building_xml|
      buildings.push(building_xml)
    end
    return buildings[0]
  end

  def create_xml_file_object(xml_file_path)
    doc = nil
    File.open(xml_file_path, 'r') do |file|
      doc = REXML::Document.new(file)
    end
    return doc
  end
end
