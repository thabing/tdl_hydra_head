#require File.expand_path(File.dirname(__FILE__) + '/hydra_jetty.rb')

require "solrizer-fedora"

if defined?(Rails) && (Rails.env == 'development')
  Rails.logger = Logger.new(STDOUT)
end

#Calling ActiveFedora.init with a path as an argument has been removed.  Use ActiveFedora.init(:fedora_config_path=>/Users/mkorcy01/Desktop/tdl_hydra_head/config/fedora.yml)

#ActiveFedora.init("#{Rails.root}/config/fedora.yml")
#ActiveFedora.init(:fedora_config_path=>"/Users/mkorcy01/Desktop/tdl_hydra_head/config/fedora.yml")
ActiveFedora.init(:fedora_config_path=>"#{Rails.root}/config/fedora.yml")

 namespace :repo do
   desc "Load the object located at the provided path or identified by pid."
   override_task :load => :environment do
     ### override the AF provided task to use the correct fixture directory
     if ENV["pid"].nil?
       raise "You must specify a valid pid.  Example: rake repo:load pid=demo:12"
     end
 puts "loading #{ENV['pid']}"
     if ENV["path"].nil?
         path = 'test_support/fixtures'
     else
         path = ENV["path"]
     end

     begin
       ActiveFedora::FixtureLoader.new(path).reload(ENV["pid"])
     rescue Errno::ECONNREFUSED => e
       puts "Can't connect to Fedora! Are you sure jetty is running?"
     rescue Exception => e
       logger.error("Received a Fedora error while loading #{ENV["pid"]}\n#{e}")
     end
   end
 end

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
	"tufts_sample001",
  "tufts_UA069.001.DO.MS124",
  "tufts_UA069.001.DO.MS134",
  "tufts_UA069.001.DO.UA015",
  "tufts_UA069.001.DO.UP022",
  "tufts_UA069.001.DO.UP029",
  "tufts_la.speakerofthehouse.1820",
  "tufts_me.uscongress3.second.1825",
  "tufts_ky.clerkofthehouse.1813"
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
	"tufts:sample001",
  "tufts:UA069.001.DO.MS124",
  "tufts:UA069.001.DO.MS134",
  "tufts:UA069.001.DO.UA015",
  "tufts:UA069.001.DO.UP022",
  "tufts:UA069.001.DO.UP029",
  "tufts:la.speakerofthehouse.1820",
  "tufts:me.uscongress3.second.1825",
  "tufts:ky.clerkofthehouse.1813"

    ]

    desc "Load default tufts_dca fixtures"
    task :load do
      TDL_FIXTURES.each_with_index do |fixture,index|
        ENV["pid"] = fixture
        ENV["path"] = "test_support/fixtures/#{Rails.env}"
        # logger.debug ENV["fixture"] 
        #Rails.logger = Logger.new(STDOUT)
        #logger.level = 0
        if ENV["pid"] == "tufts:UA069.001.DO.MS134"
          puts "BLAH"
        end
        if index == 0
          Rake::Task["repo:load"].invoke
        elsif index > 0
          Rake::Task["repo:load"].execute
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

        #don't index perseus and art history objects

        unless fixture.start_with?("tufts:aah") || fixture.start_with?("tufts:perseus")
          if index == 0
           Rake::Task["solrizer:fedora:solrize"].invoke
          elsif index > 0
            Rake::Task["solrizer:fedora:solrize"].execute
          end
        end
      end
    end

    desc "Remove default tufts_dca fixtures"
    task :delete do
      TDL_FIXTURES.each_with_index do |fixture,index|
        ENV["pid"] = fixture
        Rake::Task["repo:delete"].invoke if index == 0
        Rake::Task["repo:delete"].execute if index > 0
      end
    end

    desc "Refresh default tufts_dca fixtures"
    task :refresh do
      Rake::Task["tufts_dca:delete"].invoke
      Rake::Task["tufts_dca:load"].invoke
    end
end
