class Locality
  attr_accessor :distance

  def self.calculate(address, location)
    address = address.split(/,|\r/).drop(2).join(" ")

    results = es.search(address, per_page: 50).results

    results.each do |r|
      r.distance = Geokit::LatLng.distance_between(location.to_s, r.lat_lng.to_s)
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

end
