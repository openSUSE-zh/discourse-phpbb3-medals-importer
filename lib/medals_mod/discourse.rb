module MedalsMod
  class Discourse
    def initialize(con, data)
      @con = con
      @data = data
    end

    def push
      @data.each do |i|
        # update post_actions table
        @con.exec "INSERT INTO post_actions (post_id, user_id, post_action_type_id, created_at, updated_at, staff_took_action, targets_topic) VALUES('#{i[0]}', '#{i[2]}', '2', '#{i[5]}', '#{i[5]}', 'f', 'f')"

        # update posts table
        post_calculator = ThanksMod::PostCalculator.new(@con, i[0], i[1], i[3])
        like_count = post_calculator.like_count
        like_score = post_calculator.like_score
        score = post_calculator.score(like_score)
        @con.exec "UPDATE posts SET like_count='#{like_count}', like_score='#{like_score}', score='#{score}' WHERE id='#{i[0]}'"
        post_num = @con.exec("SELECT post_number FROM posts WHERE id='#{i[0]}'")[0]['post_number']
        @con.exec "UPDATE badge_posts SET like_count='#{like_count}', like_score='#{like_score}', score='#{score}' WHERE topic_id='#{i[3]}' AND post_number='#{post_num}'"
        pr = post_calculator.percent_rank
        @con.exec "UPDATE posts SET percent_rank='#{pr}' WHERE id='#{i[0]}'"

        # update topic_users table
        @con.exec "UPDATE topic_users SET liked='t' WHERE user_id='#{i[2]}' AND topic_id='#{i[3]}'"

        # update topics table
        topic_calculator = ThanksMod::TopicCalculator.new(@con, i[3])
        topic_likes = topic_calculator.like_count
        topic_score = topic_calculator.score
        @con.exec "UPDATE topics SET like_count='#{topic_likes}',score='#{topic_score}' WHERE id='#{i[3]}'"
        topic_pr = topic_calculator.percent_rank
        @con.exec "UPDATE topics SET percent_rank='#{topic_pr}' WHERE id='#{i[3]}'"

        # update top_topics table
        top_calculator = ThanksMod::TopCalculator.new(@con, i[3])
        op_likes = top_calculator.op_like_count
        scores = top_calculator.scores
        @con.exec "UPDATE top_topics SET yearly_likes_count='#{topic_likes}',monthly_likes_count='#{topic_likes}',weekly_likes_count='#{topic_likes}',daily_likes_count='#{topic_likes}',quarterly_likes_count='#{topic_likes}' WHERE topic_id='#{i[3]}'"
        @con.exec "UPDATE top_topics SET yearly_op_likes_count='#{op_likes}',monthly_op_likes_count='#{op_likes}',weekly_op_likes_count='#{op_likes}',daily_op_likes_count='#{op_likes}',quarterly_op_likes_count='#{op_likes}' WHERE topic_id='#{i[3]}'" 
        @con.exec "UPDATE top_topics SET daily_score='#{scores[0]}',weekly_score='#{scores[1]}',monthly_score='#{scores[2]}',quarterly_score='#{scores[3]}',yearly_score='#{scores[4]}',all_score='#{scores[5]}' WHERE topic_id='#{i[3]}'"

        # update user_actions table
        @con.exec "INSERT INTO user_actions (action_type, user_id, target_topic_id, target_post_id, acting_user_id, created_at, updated_at) VALUES ('1', '#{i[2]}', '#{i[3]}', '#{i[0]}', '#{i[2]}', '#{i[5]}', '#{i[5]}')"
        @con.exec "INSERT INTO user_actions (action_type, user_id, target_topic_id, target_post_id, acting_user_id, created_at, updated_at) VALUES ('2', '#{i[1]}', '#{i[3]}', '#{i[0]}', '#{i[2]}', '#{i[5]}', '#{i[5]}')"

        # update directory_item table
        @con.exec "UPDATE directory_items SET likes_given=likes_given + 1 WHERE user_id='#{i[2]}'"
        @con.exec "UPDATE directory_items SET likes_received=likes_received + 1 WHERE user_id='#{i[1]}'"

        # update user_stats table
        @con.exec "UPDATE user_stats SET likes_given=likes_given + 1 WHERE user_id='#{i[2]}'"
        @con.exec "UPDATE user_stats SET likes_received=likes_received + 1 WHERE user_id='#{i[1]}'"
      end
    end
  end
end
