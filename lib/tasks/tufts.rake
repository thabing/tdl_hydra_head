 #require File.expand_path(File.dirname(__FILE__) + '/hydra_jetty.rb')
require "solrizer-fedora"

#Calling ActiveFedora.init with a path as an argument has been removed.  Use ActiveFedora.init(:fedora_config_path=>/Users/mkorcy01/Desktop/tdl_hydra_head/config/fedora.yml)

#ActiveFedora.init("#{Rails.root}/config/fedora.yml")
#ActiveFedora.init(:fedora_config_path=>"/Users/mkorcy01/Desktop/tdl_hydra_head/config/fedora.yml")
ActiveFedora.init(:fedora_config_path=>"#{Rails.root}/config/fedora.yml")

namespace :tufts_dca do
    TDL_FIXTURE_FILES = [
	"tufts_MS115.003.001.00001",
	"tufts_MS115.003.001.00002",
	"tufts_MS115.003.001.00003",
	"tufts_MS122.002.001.00130",
	"tufts_MS122.002.004.00025",
	"tufts_MS122.002.021.00084",
	"tufts_MS124.001.001.00002",
	"tufts_MS124.001.001.00003",
	"tufts_MS124.001.001.00006",
	"tufts_PB.002.001.00001",
	"tufts_PB.005.001.00001",
	"tufts_RCR00001",
	"tufts_RCR00613",
	"tufts_RCR00728",
	"tufts_TBS.VW0001.000113",
	"tufts_TBS.VW0001.000386",
	"tufts_TBS.VW0001.002493",
	"tufts_UA015.012.DO.00104",
	"tufts_UA069.001.DO.MS019",
	"tufts_UA069.001.DO.MS043",
	"tufts_UA069.001.DO.MS056",
	"tufts_UA069.005.DO.00002",
	"tufts_UA069.005.DO.00015",
	"tufts_UA069.005.DO.00020",
	"tufts_UA069.005.DO.00239",
	"tufts_UA069.005.DO.00272",
	"tufts_UA069.005.DO.00339",
	"tufts_UA069.006.DO.00001",
	"tufts_UA069.006.DO.MS024",
	"tufts_UA069.006.DO.UA",
	"tufts_UP022.001.001.00001.00003",
	"tufts_UP022.001.001.00001.00004",
	"tufts_UP022.001.001.00001.00005",
	"tufts_UP029.003.003.00012",
	"tufts_UP029.003.003.00014",
	"tufts_UP029.020.031.00108",
	"tufts_WP0001",
	"tufts_sample001"
    ]
    TDL_FIXTURES = [
	"tufts:MS115.003.001.00001",
	"tufts:MS115.003.001.00002",
	"tufts:MS115.003.001.00003",
	"tufts:MS122.002.001.00130",
	"tufts:MS122.002.004.00025",
	"tufts:MS122.002.021.00084",
	"tufts:MS124.001.001.00002",
	"tufts:MS124.001.001.00003",
	"tufts:MS124.001.001.00006",
	"tufts:PB.002.001.00001",
	"tufts:PB.005.001.00001",
	"tufts:RCR00001",
	"tufts:RCR00613",
	"tufts:RCR00728",
	"tufts:TBS.VW0001.000113",
	"tufts:TBS.VW0001.000386",
	"tufts:TBS.VW0001.002493",
	"tufts:UA015.012.DO.00104",
	"tufts:UA069.001.DO.MS019",
	"tufts:UA069.001.DO.MS043",
	"tufts:UA069.001.DO.MS056",
	"tufts:UA069.005.DO.00002",
	"tufts:UA069.005.DO.00015",
	"tufts:UA069.005.DO.00020",
	"tufts:UA069.005.DO.00239",
	"tufts:UA069.005.DO.00272",
	"tufts:UA069.005.DO.00339",
	"tufts:UA069.006.DO.00001",
	"tufts:UA069.006.DO.MS024",
	"tufts:UA069.006.DO.UA",
	"tufts:UP022.001.001.00001.00003",
	"tufts:UP022.001.001.00001.00004",
	"tufts:UP022.001.001.00001.00005",
	"tufts:UP029.003.003.00012",
	"tufts:UP029.003.003.00014",
	"tufts:UP029.020.031.00108",
	"tufts:WP0001",
	"tufts:sample001"
    ]

    desc "Load default tufts_dca fixtures"
    task :load do
      TDL_FIXTURE_FILES.each_with_index do |fixture,index|
        ENV["pid"] = nil
        ENV["fixture"] = "#{Rails.root}/test_support/fixtures/#{fixture}"
        # logger.debug ENV["fixture"] 
        if index == 0
          Rake::Task["hydra:import_fixture"].invoke 
        elsif index > 0
          Rake::Task["hydra:import_fixture"].execute
        end 
      end
      TDL_FIXTURES.each_with_index do |fixture,index|
        ENV["PID"] = fixture
        if index == 0
          Rake::Task["solrizer:fedora:solrize"].invoke 
        elsif index > 0
          Rake::Task["solrizer:fedora:solrize"].execute
        end
      end
    end

    desc "Solarize fixtures without loading them"
    task:solarize do
      TDL_FIXTURES.each_with_index do |fixture,index|
        ENV["PID"] = fixture
        if index == 0
          Rake::Task["solrizer:fedora:solrize"].invoke
        elsif index > 0
          Rake::Task["solrizer:fedora:solrize"].execute
        end
      end
    end

    desc "Remove default tufts_dca fixtures"
    task :delete do
      TDL_FIXTURES.each_with_index do |fixture,index|
        ENV["pid"] = fixture
        Rake::Task["hydra:delete"].invoke if index == 0
        Rake::Task["hydra:delete"].execute if index > 0
      end
    end

    desc "Refresh default tufts_dca fixtures"
    task :refresh do
      Rake::Task["tufts_dca:delete"].invoke
      Rake::Task["tufts_dca:load"].invoke
    end
end
