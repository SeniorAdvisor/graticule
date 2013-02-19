module Graticule
  module Geocoder

    class Infochimp < Base

      def initialize(user_name, api_key)
        @apikey = api_key
        @username = user_name
        @url = URI.parse('http://api.infochimps.com/geo/utils/geolocate')
      end

      # Locates +address+ returning a Location
      def locate(address)
        get escape("f.address_text=#{address.is_a?(String) ? address : location_from_params(address).to_s}")
      end

      protected

      def make_url(params) #:nodoc
        query = "apikey=#{@username}-#{@apikey}&#{params}"
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
                                 #return result
        addr = result["results"].first
        location = Location.new(
            :longitude   => addr["coordinates"][0],
            :latitude    => addr["coordinates"][1],
            :street      => "#{addr["street_number"]} #{addr["street_name"]}".strip,
            :locality    => addr["address_locality"],
            :region      => addr["state_id"],
            :country     => addr["country_id"]
        )
        if location.longitude
          nominatim_service = Graticule::Geocoder::Nominatim.new
          nominatim_result = nominatim_service.locate(location.latitude,location.longitude)
          location.postal_code = nominatim_result.postal_code
        end
        location
      end

      # Extracts and raises any errors in +xml+
      def check_error(xml) #:nodoc
      end

    end

  end
end
