class Locality
  attr_accessor :distance

  include Mongoid::Elasticsearch

  def self.calculate(address, postcode)
    results = es.search(address).results

    results.each do |r|
      r.distance = Geokit::LatLng.distance_between(postcode.lat_lng.to_s, r.lat_lng.to_s)
    end

    sorted = results.sort_by { |r| r.distance }

    @locality = nil

    sorted.each do |r|
      if address.match(/#{Regexp.escape(r.name)}/i) && r.distance < 5
        @locality = r
        break
      end
    end

    @locality
  end

  elasticsearch!

end
