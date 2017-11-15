module MedalsMod
  class Discourse
    def initialize(con, data)
      @con = con
      @data = data
    end

    def push
      medals, users = @data
      map = {}

      time = Time.now.strftime('%Y-%m-%dT%H:%M:%SZ')
      grouping = '5' # 'Other' group

      medals.each do |medal|
        name = group_name(medal[1])
        count = count_user(medal[0], users)
        # create a group and a medal, automatically grant medal to users in this group
        @con.exec "INSERT INTO groups (name,created_at,updated_at,automatic,user_count,alias_level,automatic_membership_retroactive,primary_group,has_messages,public,allow_membership_requests,default_notification_level,visibility_level,visible,public_exit,public_admission,messageable_level,mentionable_level) VALUES('#{name}', '#{time}', '#{time}', 't', '#{count}', '0', 't', 'f', 'f', 'f', 'f', '3', '0', 't', 'f', 'f', '0', '0')"
        group_id = @con.exec("SELECT id FROM groups WHERE name='#{name}'")[0]['id']
        map[medal[0]] = group_id

        @con.exec "INSERT INTO badges (name,description,badge_type_id,grant_count,created_at,updated_at,allow_title,multiple_grant,icon,listable,target_posts,query,enabled,auto_revoke,badge_grouping_id,trigger,show_posts,system) VALUES('#{medal[1]}', '#{medal[2]}', '1', '#{count}', '#{time}', '#{time}', 'f', 'f', 'fa-certificate', 't', 'f', '#{get_query(group_id)}', 't', 't', '#{grouping}', '0', 'f', 't')"
      end

      users.each do |user|
        group = map[user[0]]
        @con.exec "INSERT INTO group_users (group_id,user_id,created_at,updated_at,owner,notification_level) VALUES('#{group}', '#{user[1]}', '#{time}', '#{time}', 'f', '3')"      
      end
    end

    private

    def group_name(name)
      name.gsub(/\s+/, '_').downcase
    end

    def count_user(id, users)
      count = 0
      users.each do |u|
        count += 1 if u[0] == id
      end
      count
    end

    def get_query(id)
      "select user_id, created_at granted_at, NULL post_id from group_users where group_id='#{id}'"
    end
  end
end
