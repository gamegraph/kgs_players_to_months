require 'nokogiri'

module KgsPlayersToMonths
  class Parser
    def initialize str
      puts sprintf "parser rcd: %d bytes", str.bytesize
      @doc = Nokogiri::HTML str
    end

    def month_urls
      if calendar_table.nil?
        puts "parser: no table of months"
        []
      else
        murls = calendar_table.css('td a').map { |a| a['href'] }
        puts sprintf "parsed: %d month urls", murls.length
        valid_urls = murls.select { |url| valid_month_url?(url) }
        puts sprintf "valid: %d urls", valid_urls.length
        valid_urls
      end
    end

    private

    def calendar_table
      @doc.css('table.grid').last
    end

    def valid_month_url? url
      /^gameArchives\.jsp
        \?user=[a-zA-Z0-9]+
        &year=[0-9]+
        &month=[0-9]+$/x =~ url
    end
  end
end
