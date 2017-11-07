module MedalsMod
  # extract thanks from phpbb3 mysql database
  class PHPBB
    def initialize(con)
      @con = con
    end

    def get
      read_data_from_thanks_table
    end

    private

    def read_data_from_thanks_table
      thanks_data = @con.query("SELECT * FROM phpbb_thanks")
      data = []
      thanks_data.each do |row|
        # post_id, poster_id, user_id, topic_id, forum_id, thanks_time
        # 4936, 2, 280, 591, 19, 1366386854
        thanks_time = get_thanks_time(row['thanks_time'])
        data << [row['post_id'], row['poster_id'], row['user_id'], thanks_time]
      end
      data
    end

    def get_thanks_time(str)
      Time.at(str.to_i).strftime('%Y-%m-%dT%H:%M:%SZ')
    end
  end
end
