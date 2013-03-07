module Graticule
  module Geocoder

    class Bing < Base

      def initialize(api_key)
        @apikey = api_key
        @url = URI.parse('http://dev.virtualearth.net/REST/v1/Locations')
      end

      # Locates +address+ returning a Location
      def locate(address)
        get escape("q=#{address.is_a?(String) ? address : location_from_params(address).to_s}")
      end

      protected

      def make_url(params) #:nodoc
        query = "#{params}&o=json&key=#{@apikey}"
        url = @url.dup
        url.query = query
        url
      end



      def prepare_response(json)
        result=JSON.parse(json)
        #Result.parse(xml, :single => true)
      end

      # Extracts a location from +xml+.
      def parse_response(result) #:nodoc:
        resultSet = result["resourceSets"].first
        addr = resultSet["resources"].first
        Location.new(
            :latitude    => addr["point"]["coordinates"][0],
            :longitude   => addr["point"]["coordinates"][1],
            :street      => addr["address"]["addressLine"],
            :locality    => addr["address"]["locality"],
            :region      => addr["address"]["adminDistrict"],
            :postal_code     => addr["address"]["postalCode"]
        )
      end

      # Extracts and raises any errors in +xml+
      def check_error(xml) #:nodoc
      end

    end

  end
end
