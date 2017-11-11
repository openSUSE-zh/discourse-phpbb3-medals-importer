module MedalsMod
  # extract medals and granted users from phpbb3 mysql database
  class PHPBB
    def initialize(con)
      @con = con
    end

    def get
      users = read_users
      medals = strip_medals(read_medals, users)
      [medals, users]
    end

    private

    def strip_medals(medals, users)
      # strip ungranted medals
      granted = []
      stripped = []
      users.each do |u|
        granted << u[0] unless granted.include?(u[0])
      end
      medals.each do |medal|
        stripped << medal if granted.include?(medal[0])
      end
      stripped
    end

    def read_medals
      raw = @con.query("SELECT id,name,description FROM phpbb_medals")
      medals = []
      raw.each do |r|
        medals << [r['id'], r['name'], r['description']]
      end
      medals
    end

    def read_users
      raw = @con.query("SELECT medal_id,user_id FROM phpbb_medals_awarded")
      users = []
      raw.each do |r|
        users << [r['medal_id'], r['user_id']]
      end
      users
    end
  end
end
