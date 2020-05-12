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