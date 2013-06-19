require 'pg'
require 'uri'

module KgsPlayersToMonths
  class Cache
    def initialize
      @conn = PG.connect connect_hash db_uri
    end

    def hit? str
      qry = 'select * from kgs_usernames where un = $1 limit 1'
      rslt = @conn.exec_params qry, [str]
      rslt.ntuples == 1
    end

    def << str
      begin
        @conn.exec_params 'insert into kgs_usernames (un) values ($1)', [str]
      rescue PG::Error => e
        unless e.message.to_s.include? 'violates unique constraint'
          raise e
        end
      end
    end

    private

    def connect_hash uri
      {
        host: uri.host,
        dbname: uri.path[1..-1],
        user: uri.user,
        password: uri.password
      }
    end

    def db_uri
      URI.parse ENV['DATABASE_URL']
    end
  end
end
