module SortingOffice
  class Address

    attr_accessor :address, :postcode, :town, :locality, :street, :paon, :saon, :provenance

    def initialize(address)
      @original = address
      @address = address
    end

    def parse
      get_postcode
      unless @postcode.nil?
        get_town
        get_street
        get_locality
        get_aon
        get_provenance
      end
    end

    def get_postcode
      @postcode = Postcode.calculate(@address)
      @address = @address.gsub(/#{@postcode.name.gsub(' ', ' ?')}/i, "") if @postcode
    end

    def get_town
      @town = Town.calculate(@address, @postcode)
      # Only remove the last instance of the town name (as the town name may be in the street too)
      @address = remove_element(@town) if @town
    end

    def get_street
      @street = Street.calculate(@address, @postcode)
      @address = remove_element(@street) if @street
    end

    def get_locality
      @locality = Locality.calculate(@address, @postcode)
      @address = remove_element(@locality) if @locality
    end

    def get_aon
      aons = []

      lines = @address.split(/\n|,|\s{2,}/)

      if lines.count > 1
        lines.each_with_index do |l, line_number|
          # Split up the line
          words = l.split(" ")
          words.each_with_index do |w, word_number|
            # Does anything start with a number?
            if w.match(/^[0-9]+/)
              aons << [
                line_number,
                word_number,
                l.strip
              ]
            end
          end
        end
      else
        # Grab the first line
        line = lines.first
        # Split by spaces
        words = line.split(" ")
        words.each_with_index do |w, word_number|
          # If the word begins with a number, it's probably an aon
          if w.match(/^[0-9]+/)
            aons << [
              aons.count,
              word_number,
              w.strip
            ]
          else
            # If there is already an aon, it's probably a suffix (such as 'floor' etc)
            aons.last[2] += " #{w.strip}"
          end
        end
      end

      # If no AONs have numbers, add the first line to the AON list
      if aons.count == 0
        @paon = lines.first.strip
      end

      # If there is only one AON found so far
      if aons.count == 1
        # Make the first AON found into the PAON
        @paon = aons.first.last

        # If the AON isn't on line 0 of the address, then there is a SAON before it
        if aons.first[0] != 0
          @saon = lines.first
        end
      elsif aons.count == 2 # If there is more than one AON
        # The PAON is the second AON we've found, for some reason
        @paon = aons[1].last
        @saon = aons[0].last
      end

    end

    def get_provenance
      @provenance = Provenance.calculate(@original, self)
    end

    private

      def remove_element(el)
        pattern = el.name.reverse.gsub(/([^0-9A-Za-z ])/, '\1?')
        @address.reverse.sub(/#{pattern}/i, "").reverse
      end

  end
end
