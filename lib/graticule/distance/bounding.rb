# encoding: UTF-8
module Graticule
  module Distance

    #
    # The Bounding Law of Cosines is the simplist though least accurate distance
    # formula (earth isn't a perfect sphere).
    #
    class Bounding < DistanceFormula
      @@MIN_LAT = -90.to_radians
      @@MAX_LAT = 90.to_radians
      @@MIN_LON = -180.to_radians
      @@MAX_LON = 180.to_radians
      # Calculate the distance between two Locations using the Bounding formula
      #
      #   Graticule::Distance::Bounding.distance(
      #     Graticule::Location.new(:latitude => 42.7654, :longitude => -86.1085),
      #     Graticule::Location.new(:latitude => 41.849838, :longitude => -87.648193)
      #   )
      #   #=> 101.061720831853
      #
      def self.distance(from, to, units = :miles)
        from_longitude  = from.longitude.to_radians
        from_latitude   = from.latitude.to_radians
        to_longitude    = to.longitude.to_radians
        to_latitude     = to.latitude.to_radians

        Math.acos(
            Math.sin(from_latitude) *
            Math.sin(to_latitude) +

            Math.cos(from_latitude) *
            Math.cos(to_latitude) *
            Math.cos(to_longitude - from_longitude)
        ) * EARTH_RADIUS[units.to_sym]
      end

      def self.bounding_box(location, distance, options= {:units => :miles})
        # radius = Graticule::Distance::EARTH_RADIUS[options[:units].to_sym]
        # if distance < 0
        #   return nil
        # end 
        # radLat = location.latitude.to_radians
        # radLon = location.longitude.to_radians
        # radDist = distance / radius
        # minLat = radLat - radDist
        # maxLat = radLat + radDist
        # minLon, maxLon = 0.0
        # if minLat > @@MIN_LAT && maxLat < @@MAX_LAT
        #   deltaLon = Math.asin(Math.sin(radDist) / Math.cos(radLat))
        #   minLon = radLon - deltaLon
        #   if minLon < @@MIN_LON
        #     minLon += Math::PI * 2
        #   end
        #   maxLon = radLon + deltaLon
        #   if maxLon > @@MAX_LON
        #     maxLON -= Math::PI * 2
        #   end
        # else
        #   minLat = [minLat, @@MIN_LAT].max
        #   maxLat = [maxLat, @@MAX_LAT].min
        #   minLon = @@MIN_LON
        #   maxLon = @@MAX_LON
        # end

        p1=endpoint(location,distance,0, options)
        p2=endpoint(location,distance,90, options)
        p3=endpoint(location,distance,180, options)
        p4=endpoint(location,distance,270, options)
        return {:minLat => p3[0], :maxLat => p1[0], :minLon => p4[1], :maxLon => p2[1]}
        #return {:minLat => minLat.to_degrees, :maxLat => maxLat.to_degrees, :minLon => minLon.to_degrees, :maxLon => maxLon.to_degrees}
      end

      def self.endpoint(location,distance,heading,options)
          radius = Graticule::Distance::EARTH_RADIUS[options[:units].to_sym]
          lat = location.latitude.to_radians
          lng = location.longitude.to_radians
          heading = heading.to_radians

          end_lat=Math.asin(Math.sin(lat)*Math.cos(distance/radius) +
                          Math.cos(lat)*Math.sin(distance/radius)*Math.cos(heading))

          end_lng=lng+Math.atan2(Math.sin(heading)*Math.sin(distance/radius)*Math.cos(lat),
                               Math.cos(distance/radius)-Math.sin(lat)*Math.sin(end_lat))

          return [end_lat.to_degrees, end_lng.to_degrees]
      end
        
      def self.to_sql(options)
        options = {
          :units => :miles,
          :latitude_column => 'latitude',
          :longitude_column => 'longitude',
          :distance => 5.0
        }.merge(options)
        box = bounding_box(options[:location], options[:distance], {:units => options[:units].to_sym})
        radius = Graticule::Distance::EARTH_RADIUS[options[:units].to_sym]
        distance_ratio = options[:distance] / radius
        %{
          (#{options[:latitude_column]} >= #{box[:minLat]} AND #{options[:latitude_column]} <= #{box[:maxLat]}) 
            AND (#{options[:longitude_column]} >= #{box[:minLon]} AND #{options[:longitude_column]} <= #{box[:maxLon]})
            AND ACOS(SIN(RADIANS(#{options[:latitude]})) *
            SIN(RADIANS(#{options[:latitude_column]})) +
            COS(RADIANS(#{options[:latitude]})) *
            COS(RADIANS(#{options[:latitude_column]})) *
            COS(RADIANS(#{options[:longitude_column]}) - RADIANS(#{options[:longitude]}))) <= #{distance_ratio}
            
        }.gsub("\n", '').squeeze(" ")
      end
    end
  end
end
