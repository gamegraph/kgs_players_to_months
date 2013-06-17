require 'net/http'
require 'uri'
require_relative 'msg_queues'
require_relative 'parser'

module KgsPlayersToMonths
  def self.run
    qs = MsgQueues.new
    while true do
      qs.deq_kpq do |msg|
        puts "player: #{msg.body}"
        if /^[a-zA-Z0-9]+$/ =~ msg.body
          player_page = Net::HTTP.get player_uri(msg.body)
          qs.enq_months Parser.new(player_page).month_urls
        end
      end
      sleep rand (30..60)
    end
  end

  def self.player_uri username
    URI("http://www.gokgs.com/gameArchives.jsp?user=" + username.to_s)
  end
end

$stdout.sync = true
KgsPlayersToMonths.run
