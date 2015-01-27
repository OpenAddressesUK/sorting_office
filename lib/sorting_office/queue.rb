module SortingOffice
  class Queue

      def self.perform(address)
        queue.post(address.to_json)
      end

      def self.ironmq
        @@ironmq ||= IronMQ::Client.new(token: ENV['IRON_MQ_TOKEN'], project_id: ENV['IRON_MQ_PROJECT_ID'], host: 'mq-aws-eu-west-1.iron.io')
      end

      def self.queue
        ironmq.queue("sorting_office")
      end

  end
end
