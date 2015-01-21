module SortingOffice
  class Provenance

    def self.calculate(original, address)
      {
        activity: {
          executed_at: DateTime.now,
          processing_scripts: "https://github.com/OpenAddressesUK/sorting_office",
          derived_from: derivations(original, address, [:postcode, :town, :locality, :street])
        }
      }
    end

    def self.derivations(original, address, parts)
      derivations = [
        {
          type: "userInput",
          input: original,
          inputted_at: DateTime.now,
          processing_script: "#{ENV['GITHUB_REPO_URL']}/tree/#{current_sha}/lib/sorting_office/address.rb"
        },
      ]

      parts.delete_if { |p| address.send(p).nil? }.each do |part|
        derivations << {
          type: "Source",
          urls: [
            part_url(address.send(part))
          ],
          downloaded_at: DateTime.now,
          processing_script: "#{ENV['GITHUB_REPO_URL']}/tree/#{current_sha}/lib/models/#{address.send(part).class.to_s.downcase}.rb"
        }
      end

      derivations
    end

    def self.part_url(part)
      "http://alpha.openaddressesuk.org/#{part.class.to_s.downcase.pluralize}/#{part.token}"
    end

    def self.current_sha
      if ENV['MONGOID_ENVIRONMENT'] == "production"
        @current_sha ||= begin
          heroku = PlatformAPI.connect_oauth(ENV['HEROKU_TOKEN'])
          slug_id = heroku.release.list(ENV['HEROKU_APP']).last["slug"]["id"]
          heroku.slug.info(ENV['HEROKU_APP'], slug_id)["commit"]
        end
      else
        @current_sha ||= `git rev-parse HEAD`.strip
      end
    end

  end
end
