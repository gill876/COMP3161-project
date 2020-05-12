DROP PROCEDURE IF EXISTS adminUserBio;
DROP PROCEDURE IF EXISTS adminUserPostTotals;
DROP PROCEDURE IF EXISTS adminUserFriendTotals;
DROP PROCEDURE IF EXISTS adminUserGroupTotals;
DROP PROCEDURE IF EXISTS adminUserCommentTotals;

DROP INDEX u_username ON user;
DROP INDEX u_user_id ON user;
DROP INDEX profile_id ON profile;
DROP INDEX up_profile_id ON userProfile;
DROP INDEX post_id ON post;
DROP INDEX comment_id ON comment;
DROP INDEX f_user_id ON friends;
DROP INDEX grp_user_id ON join_group;
DROP INDEX grp_grp_id ON join_group;

CREATE INDEX u_username ON user(username);
CREATE INDEX u_user_id ON user(user_id);
CREATE INDEX profile_id ON profile(profile_id);
CREATE INDEX up_profile_id ON userProfile(profile_id);
CREATE INDEX post_id ON post(post_id);
CREATE INDEX comment_id ON comment(comment_id);
CREATE INDEX f_user_id ON friends(user_id);
CREATE INDEX grp_user_id ON join_group(user_id);
CREATE INDEX grp_grp_id ON join_group(user_id);



DELIMITER //
    CREATE PROCEDURE adminUserBio()
    BEGIN

    SELECT user.username, profile.firstname, profile.lastname 
    FROM user
    JOIN profile
    JOIN userProfile
    ON user.user_id = userProfile.user_id
    AND profile.profile_id = userProfile.profile_id
    ORDER BY user.user_id;

    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE adminUserPostTotals()
    BEGIN

    SELECT COUNT(create_post.user_id)
    FROM create_post
    RIGHT JOIN user 
    ON create_post.user_id = user.user_id
    GROUP BY user.user_id
    ORDER BY user.user_id;

    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE adminUserFriendTotals()
    BEGIN

    SELECT COUNT(friends.user_id)
    FROM friends
    RIGHT JOIN user 
    ON friends.user_id = user.user_id
    GROUP BY user.user_id
    ORDER BY user.user_id;

    END //
DELIMITER ;

/*DELIMITER //
    CREATE PROCEDURE adminUserGroupPostTotals()
    BEGIN

        SELECT COUNT(create_post.user_id)
    FROM create_post
    RIGHT JOIN user 
    ON create_post.user_id = user.user_id
    GROUP BY user.user_id
    ORDER BY user.user_id;

    END //
DELIMITER ;
todo group post totals - not a priority
*/

DELIMITER //
    CREATE PROCEDURE adminUserGroupTotals()
    BEGIN

    SELECT COUNT(join_group.user_id)
    FROM join_group
    RIGHT JOIN user 
    ON join_group.user_id = user.user_id
    GROUP BY user.user_id
    ORDER BY user.user_id;

    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE adminUserCommentTotals()
    BEGIN

    SELECT COUNT(create_comment.user_id) 
    FROM create_comment
    RIGHT JOIN user 
    ON create_comment.user_id = user.user_id
    GROUP BY user.user_id
    ORDER BY user.user_id;

    END //
DELIMITER ;