class Town

  include Mongoid::Elasticsearch

  def self.calculate(address, postcode)
    results = es.search(address).results
    matches = []

    results.each do |r|
      Town.where(name: r.name).each do |town|
        matches << town if town.area == postcode.area
      end
    end

    if matches.count == 1
      matches.first
    elsif matches.count > 0
      matches.each do |m|
        @town = m if address.match(/#{m.name}/i)
      end
      @town
    end
  end

  elasticsearch!

end
