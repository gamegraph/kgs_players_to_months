require 'net/http'
require 'uri'
require_relative 'cache'
require_relative 'msg_queues'
require_relative 'parser'

module KgsPlayersToMonths
  ARCHIVES_JSP = "http://www.gokgs.com/gameArchives.jsp".freeze

  class Main
    def initialize
      @cache = Cache.new
      @qs = MsgQueues.new
    end

    def run
      while true do
        request_sent = false
        @qs.deq_kpq do |msg|
          request_sent = process_kpq_msg msg.body
        end
        if request_sent
          sleep rand (30..60)
        end
      end
    end

    private

    def player_uri username
      URI(ARCHIVES_JSP + "?oldAccounts=y&user=" + username.to_s)
    end

    def process_kpq_msg username
      puts "player: #{username}"
      if !username?(username)
        puts "skip: invalid"
        false
      elsif recent?(username)
        puts "skip: recent"
        false
      else
        player_page = Net::HTTP.get player_uri(username)
        @qs.enq_months Parser.new(player_page).month_urls
        @cache << username
        true
      end
    end

    def recent? username
      @cache.hit? username
    end

    def username? str
      /^[a-zA-Z0-9]+$/ =~ str
    end
  end
end

$stdout.sync = true
KgsPlayersToMonths::Main.new.run
