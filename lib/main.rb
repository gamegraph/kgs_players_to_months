require 'net/http'
require 'uri'
require_relative 'msg_queues'
require_relative 'parser'

module KgsPlayersToMonths
  class Main
    def initialize
      @recent = Set.new
      @qs = MsgQueues.new
    end

    def run
      while true do
        @qs.deq_kpq do |msg|
          process_kpq_msg msg.body
        end
        sleep rand (30..60)
      end
    end

    private

    def player_uri username
      URI("http://www.gokgs.com/gameArchives.jsp?user=" + username.to_s)
    end

    def process_kpq_msg username
      puts "player: #{username}"
      if username?(username) && !recent?(username)
        player_page = Net::HTTP.get player_uri(username)
        @qs.enq_months Parser.new(player_page).month_urls
        @recent << username
      end
    end

    def recent? username
      @recent.include? username
    end

    def username? str
      /^[a-zA-Z0-9]+$/ =~ str
    end
  end
end

$stdout.sync = true
KgsPlayersToMonths::Main.new.run
