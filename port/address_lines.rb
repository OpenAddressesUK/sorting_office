class AddressLines

  def initialize(db)            # Instantiation - takes database connection
    @unparsed = []              # Initialise unparsed address list to empty
    @postcode_area = ''         # Initialise postcode area to null string
    @townpos = [-1, -1]         # Position of town in address [line, subline, word]
    @aons = []                  # Position of addressable objects within the address
    @parsed = {}                # Formatted address elements
    @postcode_location = (0,0)  # Postcode coordinates
    @db = db
    
    # Preload list of post towns
    @towns = {}
    query = "SELECT `pcarea`, `town` FROM `Posttowns`;"
    @db.execute(query)
    @db.fetchall().each do |row|
      words = [w.translate(None,string.punctuation) for w in re.split(' |-',row[1])]
      key = words[0][:4]
      if row[0] not in @towns:
        @towns[row[0]] = {}
      end
      if key not in @towns[row[0]]:
        @towns[row[0]][key] = []
      end
      @towns[row[0]][key].append([row[1],words])
    end
  end
        
  def parse_address(address, postcode)
    @unparsed = []
    address.each do |line|
      @unparsed.concat line.split(",")
    end
    @postcode_area = postcode.getArea("S")
    @postcode_location = postcode.centroid
    @postcode = postcode.getPostcode("S")
    @townpos = [-1, -1, -1]
    @parsed = {}
    
    # Check towns and streets
    return nil if get_town.blank?
    get_street
    
    # PAON and SAON
    get_aons
    
    # Store postcode
    @parsed['postcode'] = {
      'name' => postcode.getPostcode("S"),
      'geometry' => {
        'type' => 'Point',
        'coordinates' => [postcode.centroid[1], postcode.centroid[0]]
      }
    }
    
    # Done!
    @parsed
  end
        
  def get_town_key(str)
    words = [w.translate(None,string.punctuation) for w in re.split(' |-',str.upper())]
    return [words[0][:4],words]
  end
        
  def get_town
    lineno = 0
    # Reverse search for town through unparsed address
    for i in range(len(@unparsed),0,-1):
      # Split address line by whitespace or apostrophe
      words = re.findall(r"[\w']+",@unparsed[i-1])
        # For each split word in the address line
        for j in range(0,len(words)):
          # Generate the "town key" for the split word in the unparsed address line
          keys = get_town_key(words[j])
          
          
          
                if @postcode_area in @towns:
                    if keys[0] in @towns[@postcode_area]:
                        matchwords = 0
                        town = -1
                        # print @towns[@postcode_area][keys[0]]
                        for k in range(0,len(@towns[@postcode_area][keys[0]])):
                            if @towns[@postcode_area][keys[0]][k][1][0] == keys[1][0]:
                                ntwords = len(@towns[@postcode_area][keys[0]][k][1])
                                if ntwords > matchwords:
                                    m = 1
                                    for l in range(1,ntwords):
                                        if (j+l) < len(words) and words[j+l][:2].upper() == @towns[@postcode_area][keys[0]][k][1][l][:2]:
                                            m += 1
                                    if m > matchwords:
                                        matchwords = m
                                        town = k
                                        @townpos = [i-1, j]
                        if town > -1:  
                            @parsed['town'] = {}
                            @parsed['town']['name'] = @towns[@postcode_area][keys[0]][town][0]
                            if j == 0:
                                @unparsed[i-1] = ''
                            else: 
                                @unparsed[i-1] = string.join(words[0:j], " ")
                            for k in range (i,len(@unparsed)):
                                @unparsed[k] = ''
                            return @towns[@postcode_area][keys[0]][town][0]
        
        return ''
        
  def get_street
    # As long as we have a postcode location to query against
    if @postcode_location[0] > 0
      
      # Get all streets that are near the postcode location (what's MBR25?)
      query = "SELECT `Name`, `Centx`, `Centy` FROM `OS_Locator` WHERE `Name` > '' AND CONTAINS(`MBR25` ,POINT( "+str(@postcode_location[0])+", "+str(@postcode_location[1])+"));"
      @db.execute(query)
      
      # Match streets found against each line of the address, in order
      matches = {}
      @db.fetchall.each do |street|
        # Let's have some useful variable names
        street_name = street[0]
        street_centx = street[1]
        street_centy = street[2]
        # For each address line
        for i in range(0,len(@unparsed))
          # If the street name is in this address line
          if street_name in @unparsed[i]
            # And the street name isn't already in the list
            if street_name not in matches
              matches << {
                name: street_name,
                address_line: i,
                centroid: [street_centy, street_centx]
              }
            end
          end
        end
      end        

      # If we only found one street match, this is easy
      if matches.length == 1
        # use this match
        use_street(matches[0])
        
      # If there is more than one street match, we look at the last and second last matches
      # to work out dependent streets.
      # (why only those? Presumably because there are only streets dependent on one other,
      # not street that are dependent on a dependent street)
      elsif matches.length > 1
  
        last_match = matches[-1]
        second_last_match = matches[-2]
        
        # If two streets have matched to the same line
        if last_match[:address_line] == second_last_match[:address_line]
          
          # I guess this is all because OS Locator sometimes lists dependent
          # streets as "dependent street, bigger street", not as separate
          # streets.
          # I think we have to check both orders because we don't know what order
          # they come out in the DB query.
          
          # If last is contained within second last
          if last_match[:name] in second_last_match[:name]
            # Then the second last is a dependent street of the last,
            # and we want to use that
            use_street(second_last_match)
        
          # Otherwise, the second last is contained inside the last
          elsif second_last_match[:name] in last_match[:name]
            # Then the last is a dependent street of the second last,
            # and we want to use that
            use_street(last_match)
          
          else
            # I think the previous elsif can just be an else, because
            # the match has already been done, and we know they are on the
            # same line. I think this can only happen if the street name
            # gets entered twice on different lines. If it does, we need
            # to use the next else clause for merging the two.
            raise "I don't think we should ever get here, but just in case..."
          
          end
        
        # Otherwise, we have dependent streets with fully-separated names
        else
          # Merge the last and second last street matches into one
          # Use both names, use the last address line to find locality,
          # and take the centroid from the second last one for some
          # reason. Abitrary choice? Not sure.
          # I don't understand what makes sure that they are in the right order
          # here.
          street = {
            name: last_match[:name] + ", " + second_last_match[:name],
            address_line: last_match[:address_line],
            centroid: second_last_match[:centroid]
          }
          # use_street will erase the last line - we also need to erase the second last line in this case
          @unparsed[second_last_match[:address_line]].gsub!(second_last_match[:name],"").strip!
          # use the merged street
          use_street(street)
        end
      end        
    end
  end
  
  def use_street(street)
    # Erase the street name from the unparsed address
    @unparsed[street[:address_line]].gsub!(street[:name],"").strip!
    # Store in parsed structure
    @parsed['street'] = {
      'name' => street[:name],
      'geometry' => {
        'type' => 'Point',
        'coordinates' => street[:centroid]
      }
    }
    # If this isn't the last address line
    if street[:address_line] < (len(@unparsed) - 1)
      # And as long as the next address line isn't blank and doesn't have any numbers in it            
      if @unparsed[street[:address_line]+1] != '' and not any(char.isdigit() for char in @unparsed[street[:address_line]+1])
        # Set the next address line as the locality
        @parsed['locality'] = {
          'name' => @unparsed[street[:address_line]+1]
        }
        # Erase the locality from the unparsed address
        @unparsed[street[:address_line]+1] = ''
      end
    end
  end
        
  def get_aons
    aons = []
    
    # For each non-blank address line
    for i in range(0,len(@unparsed))
      if @unparsed[i] != '':
        # Split up the line
        words = @unparsed[i].split()
        # Does anything start with a number?
        for j in range(0,len(words)):
          if words[j][0].isdigit():
            # Store the AON data in an array, with the number split out
            # 0: address line
            # 1: word number
            # 2: pre-number section
            # 3: number section
            # 4: post-number section
            @aons.append([i,j,string.join(words[0:j]," "),words[j],string.join(words[j+1:]," ")])
          end
        end
        
        # If no AONs have numbers, add the first line to the AON list
        if @aons == []:
          @aons.append([0,0,0,"",@unparsed[0],""])
        end
  
        # If there is only one AON found so far
        if len(@aons) == 1:
          # Make the first AON found into the PAON
          @parsed['paon'] = {
            # Use the number and anything after it
            'name' => (@aons[0][3]+" "+@aons[0][4]).strip()
          }
          # If the AON isn't on line 0 of the address, then there is a SAON before it
          # house name, etc, so store that too.
          if @aons[0][0] > 0:
            @parsed['saon'] = {
              'name' => @unparsed[0]
            }
          end
                
        # If there is more than one AON
        elsif len(@aons) >= 2
          # The PAON is the second AON we've found, for some reason
          @parsed['paon'] = {
            'name' => (@aons[1][3]+" "+@aons[1][4]).strip()
          }
          # The SAON is the first line of the address
          @parsed['saon'] = {
            'name' => @unparsed[0].strip()
          }
          # I assume everything else gets thrown away.
        end
        
        @aons
      end
    end
  end
  
end
