require_relative './collections'
require 'chicanery/site'
require 'nokogiri'
require 'httparty'

module Chicanery
  module Bamboo
    include Chicanery::Collections
    def self.new *args
      Bamboo::Server.new *args
    end

    def bamboo *args
      server Bamboo::Server.new(*args)
    end

    class Server
      attr_reader :name

      def initialize name, url, options
        @name, @url, @options = name, url, options
      end

      def jobs
        jobs = { }
        @options[:projects].each do |project_name|
          puts "Fetching #{@url}/rest/api/latest/result/#{project_name}"
          build_results = HTTParty.get("#{@url}/rest/api/latest/result/#{project_name}")
          latest_result = build_results['results']['results']['result'].first
          job = {
            activity: '',
            last_build_status: latest_result['state'] == 'Successful' ? :success : :failure,
            last_build_time: '',
            url: latest_result['link']['href'],
            last_label: latest_result['key']
          }
          jobs[project_name] = job
        end
        jobs
      end
    end
  end
end

