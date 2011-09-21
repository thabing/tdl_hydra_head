# require File.expand_path(File.dirname(__FILE__) + '/hydra_jetty.rb')
require "solrizer-fedora"

namespace :tufts_dca do
    TDL_FIXTURE_FILES = [
        "tufts_UA005.036.001.00001.xml",
        "tufts_UA069.004.001.00014.xml"
    ]
    TDL_FIXTURES = [
        "tufts:UA005.036.001.00001",
        "tufts:UA069.004.001.00014"
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
