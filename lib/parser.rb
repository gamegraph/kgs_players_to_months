require 'nokogiri'

module KgsPlayersToMonths
  class Parser
    def initialize str
      puts sprintf "parser rcd: %d bytes", str.bytesize
      @doc = Nokogiri::HTML str
    end

    def month_urls
      murls = @doc.css('table.grid td a').map { |a| a['href'] }
      puts sprintf "parsed: %d month urls", murls.length
      murls
    end

  end
end
