@output = []

companyreader.each_with_index do |row, row_index|
  # Check the line has a postcode
  next if row['RegAddress.PostCode'].blank?

  postcode = Postcode(row['RegAddress.PostCode'],db)
  next unless postcode.current?
  lines = [row['RegAddress.AddressLine1'], row['RegAddress.AddressLine2'], row['RegAddress.PostTown'], row['RegAddress.County']]
          
  # Parse all the things
  parsed = AddressLines.new(db).parse_address(lines,postcode)
  next if parsed.nil?
  
  # Build output structure
  address = {
    'address' => parsed,
    'provenance' = {
      'executed_at' => datetime.datetime.today().strftime("%Y-%m-%dT%H:%M:%SZ"),
      'url' => "http://download.companieshouse.gov.uk/en_output.html",
      'filename' => file,
      'record_no' => row_index.to_s
    }
  }
  @output.append(address)
end