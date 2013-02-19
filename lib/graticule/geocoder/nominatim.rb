module Graticule
  module Geocoder

    class Nominatim < Base

      def initialize()
        @url = URI.parse('http://nominatim.openstreetmap.org/reverse')
      end

      # Returning a Location by latitude and logitude
      def locate(latitude,longitude)
        get escape("lat=#{latitude}&lon=#{longitude}")
      end

      protected

      def make_url(params) #:nodoc
        query = "format=json&zoom=18&addressdetails=1&#{params}"
        url = @url.dup
        url.query = query
        puts "######"
        puts url
        url
      end

      def prepare_response(json)
        result=JSON.parse(json)
      end

      # Extracts a location from +xml+.
      def parse_response(result) #:nodoc:
                                 #return result
        addr = result["address"]
        puts addr["postcode"]
        Location.new(
            :postal_code  => addr["postcode"],
            :region    => addr["state"],
            :country     => addr["country_code"]
        )
      end

      # Extracts and raises any errors in +xml+
      def check_error(xml) #:nodoc
      end

    end

  end
end
