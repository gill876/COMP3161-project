/*
DROP PROCEDURE IF EXISTS adminGroupPostTotals;
DELIMITER //
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


DROP PROCEDURE IF EXISTS adminGroupName;
DROP PROCEDURE IF EXISTS adminGroupCreatorByUserId;
DROP PROCEDURE IF EXISTS getGrpTotalMembers;


DELIMITER //
    CREATE PROCEDURE adminGroupName()
    BEGIN

    SELECT user_group.group_name
    FROM user_group
    GROUP BY user_group.group_id
    ORDER BY user_group.group_id;

    END//
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE adminGroupCreatorByUserId()
    BEGIN

    SELECT CONCAT(`firstname`, ' ', `lastname`)
    FROM profile
    JOIN userProfile
    JOIN create_group
    ON profile.profile_id = userProfile.profile_id
    AND userProfile.user_id = create_group.user_id
    GROUP BY create_group.group_id
    ORDER BY create_group.group_id;

    END//
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE getGrpTotalMembers()
    BEGIN

    SELECT COUNT(join_group.group_id)
    FROM join_group
    RIGHT JOIN create_group
    ON join_group.group_id = create_group.group_id
    GROUP BY create_group.group_id 
    ORDER BY create_group.group_id;

    END//
DELIMITER ;

