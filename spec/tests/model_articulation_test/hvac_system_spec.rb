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

RSpec.describe 'HVACSystemSpec' do
  it 'Should add a Exhaust in HVAC system successfully' do
    model = OpenStudio::Model::Model.new
    standard = Standard.build('DOE Ref 1980-2004')
    hvac_system = BuildingSync::HVACSystem.new
    puts 'expected : true but got: false} ' if hvac_system.add_exhaust(model, standard, 'Adjacent', false) != true
    expect(hvac_system.add_exhaust(model, standard, 'Adjacent', false)).to be true
  end

  it 'Should add a Thermostats in HVAC System successfully' do
    model = OpenStudio::Model::Model.new
    hvac_system = BuildingSync::HVACSystem.new
    puts 'expected : true but got: false} ' if hvac_system.add_thermostats(model, ASHRAE90_1, false) != true
    expect(hvac_system.add_thermostats(model, ASHRAE90_1, false)).to be true
  end

  it 'Should add HVAC System successfully' do
    model = OpenStudio::Model::Model.new
    standard = Standard.build('DOE Ref 1980-2004')
    hvac_system = BuildingSync::HVACSystem.new
    puts 'expected : true but got: false} ' if hvac_system.add_hvac(model, nil, standard, 'PSZ-AC with gas coil heat', 'Forced Air', 'NaturalGas', 'Electricity', true) != true
    expect(hvac_system.add_hvac(model, nil, standard, 'PSZ-AC with gas coil heat', 'Forced Air', 'NaturalGas', 'Electricity', true)).to be true
  end

  it 'Should apply sizing and assumptions in HVAC System' do
    model = OpenStudio::Model::Model.new
    standard = Standard.build('DOE Ref 1980-2004')
    hvac_system = BuildingSync::HVACSystem.new

    output_path = File.expand_path("../../output/#{File.basename(__FILE__, File.extname(__FILE__))}/", File.dirname(__FILE__))
    puts 'expected : false but got: true} ' if hvac_system.apply_sizing_and_assumptions(model, output_path, standard, 'Retail', 'PSZ-AC with gas coil heat', '') != false
    expect(hvac_system.apply_sizing_and_assumptions(model, output_path, standard, 'Retail', 'PSZ-AC with gas coil heat', '')).to be false
  end

  it 'Should return typical_occupant_usage_value_weeks ' do
    hvac_system = get_hvac_system_from_file('building_151_level1.xml', ASHRAE90_1)
    expected_value = 'VAVwReheat'
    puts "hvac_system #{hvac_system}"
    puts "expected primary_hvac_system_type : #{expected_value} but got: #{hvac_system.get_primary_hvac_system_type} " if hvac_system.get_primary_hvac_system_type != expected_value
    expect(hvac_system.get_primary_hvac_system_type == expected_value).to be true
  end

  def get_hvac_system_from_file(xml_file_name, standard_to_be_used)
    xml_file_path = File.expand_path("../../files/#{xml_file_name}", File.dirname(__FILE__))
    File.open(xml_file_path, 'r') do |file|
      doc = REXML::Document.new(file)
      ns = 'auc'
      doc.elements.each("/#{ns}:BuildingSync/#{ns}:Facilities/#{ns}:Facility/#{ns}:Systems/#{ns}:HVACSystems") do |hvac_system|
        return BuildingSync::HVACSystem.new(hvac_system, ns)
      end
    end
  end
end
