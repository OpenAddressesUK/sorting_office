class Town

  include Mongoid::Elasticsearch

  def self.calculate(address, postcode)
    results = es.search(address).results
    results.each do |r|
      @town = r if r.area == postcode.area
    end
    @town
  end

  elasticsearch!
  
end
