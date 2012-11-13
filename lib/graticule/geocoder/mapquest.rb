module Graticule
  module Geocoder

    class Mapquest < Base
       PRECISION = {
        'L1' => Precision::Address,
        'I1' => Precision::Street,
        'B1' => Precision::Street,
        'B2' => Precision::Street,
        'B3' => Precision::Street,
        'Z3' => Precision::PostalCode,
        'Z4' => Precision::PostalCode,
        'Z2' => Precision::PostalCode,
        'Z1' => Precision::PostalCode,
        'A5' => Precision::Locality,
        'A4' => Precision::Region,
        'A3' => Precision::Region,
        'A1' => Precision::Country
      }

      def initialize(client_id, password)
        @password = password
        @client_id = client_id
        @url = URI.parse('http://www.mapquestapi.com/geocoding/v1/address')
      end

      # Locates +address+ returning a Location
      def locate(address)
        get escape("location=#{address.is_a?(String) ? address : location_from_params(address).to_s}")
      end

      protected

      def make_url(params) #:nodoc
        query = "key=#{@client_id}&inFormat=kvp&outFormat=json&#{params}"
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
        addr = result["results"].first["locations"].first
        Location.new(
          :latitude    => addr["latLng"]["lat"],
          :longitude   => addr["latLng"]["lng"],
          :street      => addr["street"],
          :locality    => addr["adminArea5"],
          :region      => addr["adminArea3"],
          :postal_code => addr["postalCode"],
          :country     => addr["adminArea1"],
          :precision   => Precision::Address#addr["geocodeQuality"]
        )
      end

      # Extracts and raises any errors in +xml+
      def check_error(xml) #:nodoc
      end

      def authentication_string
        "<Authentication Version=\"2\"><Password>#{@password}</Password><ClientId>#{@client_id}</ClientId></Authentication>"
      end

      def address_string(query)
        "<Address><Street>#{query}</Street></Address><GeocodeOptionsCollection Count=\"0\"/>"
      end
    end

  end
end
