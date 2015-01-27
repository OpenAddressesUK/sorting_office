[![Build Status](http://img.shields.io/travis/OpenAddressesUK/sorting_office.svg?style=flat-square)](https://travis-ci.org/OpenAddressesUK/sorting_office)
[![Dependency Status](http://img.shields.io/gemnasium/OpenAddressesUK/sorting_office.svg?style=flat-square)](https://gemnasium.com/OpenAddressesUK/sorting_office)
[![Coverage Status](http://img.shields.io/coveralls/OpenAddressesUK/sorting_office.svg?style=flat-square)](https://coveralls.io/r/OpenAddressesUK/sorting_office)
[![Code Climate](http://img.shields.io/codeclimate/github/OpenAddressesUK/sorting_office.svg?style=flat-square)](https://codeclimate.com/github/OpenAddressesUK/sorting_office)
[![Badges](http://img.shields.io/:badges-5/5-ff6799.svg?style=flat-square)](https://github.com/badges/badgerbadgerbadger)

# Sorting Office

A Sinatra app that takes a UK address string and attempts to parse it into its constituent parts.

Addresses are hard, we should know! So we've built this handy app to help you navigate around this thorny issue.

## How to use

Simply POST your address string like so (using curl):

    curl --data "address=10 Downing Street, London, SW1A 2AA" http://sorting-office.openaddressesuk.org/address

If you'd like to submit the address you're using to the OpenAddresses project, then set `contribute=true` like so:

    curl --data "address=10 Downing Street, London, SW1A 2AA&contribute=true" http://sorting-office.openaddressesuk.org/address

Please make sure you check with your users first! And be sure not to violate others' intellectual property or privacy rights with your submission.

You'd get the following response in JSON format:

    {
      "saon": null,
      "paon": "10",
      "street": "Downing Street",
      "locality": null,
      "town": "London",
      "postcode": "SW1A 2AA",
      "provenance": {
        "activity": {
          "executed_at": "2015-01-21T16:18:32+00:00",
          "processing_scripts": "https://github.com/OpenAddressesUK/sorting_office",
          "derived_from": [
          {
            "type": "userInput",
            "input": "10 Downing Street, London, SW1A 2AA",
            "inputted_at": "2015-01-21T16:18:32+00:00",
            "processing_script": "https://github.com/OpenAddressesUK/sorting_office/tree/7dd23cb19709680646a20dddfeb18b53ea4346e2/lib/sorting_office/address.rb"
            },
            {
              "type": "Source",
              "urls": [
              "http://alpha.openaddressesuk.org/postcodes/Uxm2vc"
              ],
              "downloaded_at": "2015-01-21T16:18:32+00:00",
              "processing_script": "https://github.com/OpenAddressesUK/sorting_office/tree/7dd23cb19709680646a20dddfeb18b53ea4346e2/lib/models/postcode.rb"
              },
              {
                "type": "Source",
                "urls": [
                "http://alpha.openaddressesuk.org/towns/qyHZe2"
                ],
                "downloaded_at": "2015-01-21T16:18:32+00:00",
                "processing_script": "https://github.com/OpenAddressesUK/sorting_office/tree/7dd23cb19709680646a20dddfeb18b53ea4346e2/lib/models/town.rb"
                },
                {
                  "type": "Source",
                  "urls": [
                  "http://alpha.openaddressesuk.org/streets/Gq5142"
                  ],
                  "downloaded_at": "2015-01-21T16:18:32+00:00",
                  "processing_script": "https://github.com/OpenAddressesUK/sorting_office/tree/7dd23cb19709680646a20dddfeb18b53ea4346e2/lib/models/street.rb"
                }
                ]
              }
            }
          }

If you’d rather not see the provenance data, you can add `noprov=true` to your request, like so:

      curl --data "address=10 Downing Street, London, SW1A 2AA&noprov=true" https://sorting-office.openaddressesuk.org/address

It's that simple!

The only caveat is that you must provide a valid postcode with your request, otherwise the service won't be able to calculate the other address parts. If a postcode is missing or invalid, the service will return a `400` error code and the following JSON:

    {
      "error": "We couldn't detect a postcode in your address. Please resubmit with a valid postcode."
    }

## Edge cases

We know that there are [lots of edge cases with addresses](https://www.mjt.me.uk/posts/falsehoods-programmers-believe-about-addresses/), and we know that we might not have caught 100% of them. If there's anything you notice, please [let us know](https://github.com/OpenAddressesUK/sorting_office/issues), or better still [open a pull request to fix it!](https://github.com/OpenAddressesUK/sorting_office/pulls).

## Running in development

If you haven't already, install the external dependencies below

  * [MongoDB](http://docs.mongodb.org/manual/installation/)
  * [Elasticsearch](http://www.elasticsearch.org/guide/en/elasticsearch/guide/current/_installing_elasticsearch.html)

Clone the repo:

    git clone git@github.com:OpenAddressesUK/sorting_office.git

Bundle:

    bundle install

Run the bootstrap script:

    bundle exec rake bootstrap

This will download and import a copy of the locality, street, postcode and town databases, and run the Elasticsearch indexes, which may take some time. Why not make a cup of tea?

Spin up the server

    bundle exec rackup

The server will now be running at http://localhost:9292

## Tests

To run the standard test suite, simply run:

    bundle exec rake

We have another set of tests, which we know don't all pass. This takes some of the edge cases detailed in the [Falsehoods programmers believe about addresses](https://www.mjt.me.uk/posts/falsehoods-programmers-believe-about-addresses/) blog post, as well as some of the others we've encountered on our travels, and tries to parse them all correctly. If you're interested in helping out, getting some of these tests to pass would be amazing! To run these tests, simply run

    rspec spec/big_old_list_spec.rb

And watch the fail! Currently there are 8 failing tests out of 25 in total.
