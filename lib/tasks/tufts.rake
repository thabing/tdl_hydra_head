#require File.expand_path(File.dirname(__FILE__) + '/hydra_jetty.rb')
require 'ci/reporter/rake/rspec'     # use this if you're using RSpec
require 'ci/reporter/rake/cucumber'  # use this if you're using Cucumber

require "solrizer-fedora"

if defined?(Rails) && (Rails.env == 'development')
  Rails.logger = Logger.new(STDOUT)
end


require 'metric_fu'
MetricFu::Configuration.run do |config|
  config.metrics = [:churn, :saikuro, :stats, :flog, :flay]
  config.graphs = [:flog, :flay, :stats]
  config.rcov[:test_files] = ['spec/**/*_spec.rb']
  config.rcov[:rcov_opts] << "-Ispec" # Needed to find spec_helper
end

#Calling ActiveFedora.init with a path as an argument has been removed.  Use ActiveFedora.init(:fedora_config_path=>/Users/mkorcy01/Desktop/tdl_hydra_head/config/fedora.yml)

#ActiveFedora.init("#{Rails.root}/config/fedora.yml")
ActiveFedora.init(:fedora_config_path => "#{Rails.root}/config/fedora.yml")

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
      "tufts:ky.clerkofthehouse.1813",
      "tufts:MS115.001.DO.11090",
      "tufts:UA069.005.DO.00094",
      "tufts:UA069.005.DO.00001",
      "tufts:UA069.005.DO.00026",
      "tufts:MS054.003.DO.02108",
      "tufts:UA069.005.DO.00090",
      "tufts:UA069.005.DO.00094",
      "tufts:UP150.001.019.00001"

  ]

  desc "Load default Hydra fixtures"
    task :load do
      TDL_FIXTURES.each do |fixture|
        ENV["pid"] = fixture
        ENV["path"] = 'test_support/fixtures/tdldev'
        Rake::Task["repo:load"].reenable
        Rake::Task["repo:load"].invoke
      end
    end

    desc "Remove default Hydra fixtures"
    task :delete do
      TDL_FIXTURES.each do |fixture|
        ENV["pid"] = fixture
        Rake::Task["repo:delete"].reenable
        Rake::Task["repo:delete"].invoke
      end
    end

  desc "Refresh default Hydra fixtures"
  task :refresh => [:delete, :load]

  desc "Execute Continuous Integration build (docs, tests with coverage)"
  task :ci => :environment do
    #Rake::Task["hyhead:doc"].invoke
    Rake::Task["jetty:config"].invoke
    #Rake::Task["db:drop"].invoke
    #Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke

    require 'jettywrapper'
    jetty_params = Jettywrapper.load_config.merge({:jetty_home => File.expand_path(File.join(Rails.root, 'jetty'))})

    error = nil
    error = Jettywrapper.wrap(jetty_params) do
      Rake::Task['ci:setup:rspec spec'].invoke
#      Rake::Task['spec'].invoke
      Rake::Task['cucumber:ok'].invoke
    end
    raise "test failures: #{error}" if error
  end

end
