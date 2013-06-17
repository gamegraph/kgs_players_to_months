require 'aws/sqs'

module KgsPlayersToMonths
  class MsgQueues
    def initialize
      sqs = AWS::SQS.new aws_cred
      @kpq = sqs.queues.named('gagra_kgs_players')
      @kmonq = sqs.queues.named('gagra_kgs_months')
    end

    def deq_kpq
      @kpq.receive_message { |msg| yield msg }
    end

    def enq_months month_urls
      murls = month_urls.dup
      until murls.empty? do
        batch = murls.shift(10)
        @kmonq.batch_send batch
        puts sprintf "enqueued: %d month urls", batch.length
      end
    end

    private

    def aws_cred
      {
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      }
    end
  end
end
