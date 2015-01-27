require 'spec_helper'

describe SortingOffice::Queue do

  it "posts to RabbitMQ" do
    address = {
      "saon" => "3rd Floor",
      "paon" => "65",
      "street" => "Clifton Street",
      "locality" => nil,
      "town" => "London",
      "postcode" => "EC2A 4JE"
    }

    allow_any_instance_of(IronMQ::Client).to receive(:queue).with("sorting_office").and_call_original
    allow_any_instance_of(IronMQ::Queue).to receive(:post).with(address.to_json)

    SortingOffice::Queue.perform(address)
  end

end
