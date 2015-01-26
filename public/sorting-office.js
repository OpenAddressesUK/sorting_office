// sorting-office.js
//
// A jQuery example for using Sorting Office in a client-side application.
//
// Assumes the following HTML layout:
//
// <div class="alert alert-danger hidden" role="alert">
// <p><strong>Sorry!</strong> There seems to be a problem with the address you entered. Please try again</p>
// </div>
//
// <p><textarea class="form-control" rows="4" id="address"></textarea></p>
//
// <p><button type="button" class="btn btn-primary" id="submit">Submit</button></p>
//
// <div class="well hidden">
// <p><strong><acronym title="Secondary Addressable Object">SAON</acronym>:</strong> <span id="saon"></span></p>
// <p><strong><acronym title="Primary Addressable Object">PAON</acronym>:</strong> <span id="paon"></span></p>
// <p><strong>Street:</strong> <span id="street"></span></p>
// <p><strong>Locality:</strong> <span id="locality"></span></p>
// <p><strong>Town:</strong> <span id="town"></span></p>
// <p><strong>Postcode:</strong> <span id="postcode"></span></p>
// </div>

$(document).ready(function() {
  $('#submit').click(function() { // When submit is clicked
    $.post( "http://sorting-office.openaddressesuk.org/address", { address: $('#address').val() } ) // Post to the sorting office application
    .done(function( data ) { // If the request is successful
      $('.alert').addClass('hidden'); // Hide the error alert (if not already hidden)
      $.each([ // Loop through each potential address part
        'saon',
        'paon',
        'street',
        'locality',
        'town',
        'postcode'
        ], function(i, el) {
          $('#' + el).text(""); // Clear any previous text from the named element
          if (data[el] != null) {
            $('#' + el).text(data[el]); // Populate the named element with the relevant address part
          }
        })
        $('.well').removeClass('hidden'); // Unhide the div which contains the results
      })
      .error(function() { // If there's an error
        $('.well').addClass('hidden'); // Hide the address container (if not already hidden)
        $('.alert').removeClass('hidden'); // Unhide the error alert
      }
    );
  })
})
