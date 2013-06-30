Bundler.require
require 'net/http'
require 'uri'
require_relative 'parser'

module KgsPlayersToMonths
  ARCHIVES_JSP = "http://www.gokgs.com/gameArchives.jsp".freeze

  class Main
    def initialize
      ArGagra.connect
    end

    def run
      while true do
        request_sent = false
        kun = KgsUsername.where(requested: false).first
        if kun.present?
          request_sent = process_un(kun)
        end
        if request_sent
          sleep rand (30..60)
        end
      end
    end

    private

    def insert_month_urls urls
      known = KgsMonthUrl.where('url in (?)', urls).to_a.map(&:url)
      discovered = (Set.new(urls) - known).to_a
      puts sprintf "discovered: %d urls", discovered.length
      KgsMonthUrl.import_valid(discovered)
    end

    def player_uri username
      URI(ARCHIVES_JSP + "?oldAccounts=y&user=" + username.to_s)
    end

    def process_un kun
      username = kun.un
      puts "player: #{username}"
      if !username?(username)
        puts "skip: invalid"
        false
      else
        player_page = Net::HTTP.get player_uri(username)
        insert_month_urls Parser.new(player_page).month_urls
        kun.update_attributes!(requested: true)
        true
      end
    end

    def username? str
      /^[a-zA-Z0-9]+$/ =~ str
    end
  end
end

$stdout.sync = true
KgsPlayersToMonths::Main.new.run
