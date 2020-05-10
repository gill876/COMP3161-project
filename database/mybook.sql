/*COMP3161 PROJECT*/
DROP TABLE IF EXISTS contains;
DROP TABLE IF EXISTS create_post;
DROP TABLE IF EXISTS create_comment;
DROP TABLE IF EXISTS join_group;
DROP TABLE IF EXISTS create_group;
DROP TABLE IF EXISTS profile;
DROP TABLE IF EXISTS comment;
DROP TABLE IF EXISTS user_group;
DROP TABLE IF EXISTS friends;
DROP TABLE IF EXISTS images;
DROP TABLE IF EXISTS post;
DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS csv_users; /*TABLE USED TO STORE INFORMATION FOR USER AND PROFILE TABLES FROM CSV FILE*/

DROP TRIGGER IF EXISTS Load_User_Profile; /*TRIGGER USED TO POPULATE USER AND PROFILE TABLES FROM CSV TABLE*/
/*SHOW WARNINGS;*/
DROP TRIGGER IF EXISTS updateFriendsAmount;
/*SHOW WARNINGS;*/

DROP PROCEDURE IF EXISTS loginUser; /*PURPOSE:{LOGS A USER IN USING USERNAME OR EMAIL AND PASSWORD} INPUT:{username OR email address, password in plain text} OUTPUT:{'Login successful' OR 'Password incorrect' OR 'User does not exist'}*/
DROP PROCEDURE IF EXISTS getUserID; /*PURPOSE:{RETRIEVES USER ID FROM USERNAME OR EMAIL} INPUT:{username, email address} OUTPUT:{userID}*/
DROP PROCEDURE IF EXISTS createPost; /*PURPOSE:{CREATE POST} INPUT:{userID, content in plain text, location} OUTPUT:{NO OUTPUT}*/
DROP PROCEDURE IF EXISTS createImagePost; /*PURPOSE:{CREATE IMAGE POST} INPUT:{userID, content in plain text, location, file name with path} OUTPUT:{NO OUTPUT}*/
DROP PROCEDURE IF EXISTS createComment; /*PURPOSE:{CREATE COMMENT FOR A POST} INPUT:{userID, postID, comment in plain text, location} OUTPUT:{NO OUTPUT}*/
DROP PROCEDURE IF EXISTS createGroup; /*PURPOSE:{CREATE A GROUP} INPUT:{userID, group name in plain text, group description in plain text} OUTPUT:{NO OUTPUT}*/
DROP PROCEDURE IF EXISTS joinGroup; /*PURPOSE:{JOIN A GROUP} INPUT:{userID, groupID, member role['MEMBER' OR 'CONTENT EDITOR']} OUTPUT:{NO OUTPUT}*/
DROP PROCEDURE IF EXISTS showUserPosts; /*PURPOSE:{SHOWS POSTS OF A USER} INPUT:{userID} OUTPUT:{TABLE WITH: postID, content, date and time, location}*/
DROP PROCEDURE IF EXISTS showUserImages; /*PURPOSE:{SHOWS IMAGE POSTS OF A USER} INPUT:{userID} OUTPUT:{TABLE WITH: postID, content, image name with path, date and time, location}*/
DROP PROCEDURE IF EXISTS showUserComments; /*PURPOSE:{SHOWS ALL COMMENTS CREATED BY A USER} INPUT:{userID} OUTPUT:{TABLE WITH: commentID, comment, date and time, location}*/
DROP PROCEDURE IF EXISTS showUserGroups; /*PURPOSE:{SHOWS GROUPS A USER IS ASSOCIATED WITH} INPUT:{userID} OUTPUT:{TABLE WITH: userID, groupID, member_role}*/
DROP PROCEDURE IF EXISTS addFriend; /*PURPOSE:{ADD A FRIEND TO A USER} INPUT:{userID, friendID, friend_type['WORK' OR 'SCHOOL' OR 'RELATIVE' OR 'FRIEND' OR 'ACQUAINTANCE' OR 'OTHER']} OUTPUT:{NO OUTPUT}*/
DROP PROCEDURE IF EXISTS showUserFriends; /*PURPOSE:{SHOWS FRIENDS OF A USER} INPUT:{userID} OUTPUT:{TABLE WITH: friendID, friend_type}*/
DROP PROCEDURE IF EXISTS postCreator; /*PURPOSE:{DISPLAYS USER ID OF A POST} INPUT{postID}} OUTPUT:{userID}*/
DROP PROCEDURE IF EXISTS commentCreator; /*PURPOSE:{DISPLAYS USER ID OF A COMMENT} INPUT:{commentID} OUTPUT:{userID}*/
DROP PROCEDURE IF EXISTS groupCreator; /*PURPOSE:{DISPLAYS USER ID OF A GROUP} INPUT:{groupID} OUTPUT:{userID}*/
DROP PROCEDURE IF EXISTS getPostComments; /*PURPOSE:{GET COMMENTS FOR A POST} INPUT:{postID} OUTPUT:{commentID, comment, location}*/
DROP PROCEDURE IF EXISTS numFriends; /*PURPOSE:{DISPLAYS NUMBER OF FRIENDS FOR A USER} INPUT:{userID} OUTPUT:{TABLE WITH: # of friends}*/
DROP PROCEDURE IF EXISTS numTypeFriends; /*PURPOSE:{DISPLAYS THE NUMBER OF FRIENDS OF A TYPE FOR A USER} INPUT:{userID, friend_type['WORK' OR 'SCHOOL' OR 'RELATIVE' OR 'FRIEND' OR 'ACQUAINTANCE' OR 'OTHER']} OUTPUT:{TABLE WITH: # of friends of entered type}*/
DROP PROCEDURE IF EXISTS listFriendIDs; /*PURPOSE:{DISPLAYS ALL FRIEND ID'S OF A USER} INPUT:{userID} OUTPUT:{TABLE WITH: all friendID for entered user}*/
DROP PROCEDURE IF EXISTS listTypeFriendIDs; /*PURPOSE:{DISPLAYS FRIEND ID'S OF A TYPE FOR A USER} INPUT:{userID, friend_type['WORK' OR 'SCHOOL' OR 'RELATIVE' OR 'FRIEND' OR 'ACQUAINTANCE' OR 'OTHER']} OUTPUT:{TABLE WITH: all friendID of friend_type for entered userID}*/
DROP PROCEDURE IF EXISTS signUp;
DROP PROCEDURE IF EXISTS userDetails;
DROP PROCEDURE IF EXISTS updateProfilePicture;
DROP PROCEDURE IF EXISTS updateBiography;
DROP PROCEDURE IF EXISTS changePassword;

/*USED TO POPULATE USER AND PROFILE TABLE FROM CSV*/
CREATE TABLE csv_users(
    id INT NOT NULL,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(70) NOT NULL,
    password VARCHAR(256) NOT NULL,
    firstname VARCHAR(75) NOT NULL,
    lastname VARCHAR(75) NOT NULL,
    gender VARCHAR(10) NOT NULL
);

CREATE TABLE user(
    user_id INT NOT NULL AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL UNIQUE,
    email_address VARCHAR(70) NOT NULL,
    user_password VARCHAR(256) NOT NULL,
    datejoined DATE NOT NULL,
    PRIMARY KEY(user_id)
);

CREATE TABLE profile(
    profile_id INT NOT NULL AUTO_INCREMENT,
    user_id INT DEFAULT 0 NOT NULL,
    firstname VARCHAR(75) NOT NULL,
    lastname VARCHAR(75) NOT NULL,
    /*username VARCHAR(100) NOT NULL UNIQUE,*/
    profile_img VARCHAR(100) DEFAULT 'GENERIC' NOT NULL,
    friends INT DEFAULT 0 NOT NULL,
    biography VARCHAR(300) DEFAULT "Hey there! I'm using MyBook" NOT NULL, /*change in data dictionary*/
    gender VARCHAR(10) NOT NULL,
    PRIMARY KEY(profile_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE post(
    post_id INT NOT NULL AUTO_INCREMENT,
    /*user_id INT NOT NULL,*/
    content VARCHAR(300) NOT NULL, /*change in data dictionary*/
    time_stamp DATETIME NOT NULL,
    post_location VARCHAR(70) DEFAULT "Somewhere on Earth" NOT NULL,
    PRIMARY KEY(post_id)/*,
    FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE*/
);

CREATE TABLE user_group( /*change in data dictionary*/
    group_id INT NOT NULL AUTO_INCREMENT, /*change in data dictionary*/
    group_name VARCHAR(90) NOT NULL,
    group_description VARCHAR(300) NOT NULL, /*change in data dictionary*/
    PRIMARY KEY(group_id)
);

CREATE TABLE comment(
    comment_id INT NOT NULL AUTO_INCREMENT, /*change in data dictionary*/
    post_id INT NOT NULL,
    comm_text VARCHAR(300),
    time_stamp DATETIME NOT NULL,
    c_location VARCHAR(70) DEFAULT "Somewhere on Earth" NOT NULL,
    PRIMARY KEY(comment_id, post_id),
    FOREIGN KEY(post_id) REFERENCES post(post_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE friends(
    user_id INT NOT NULL,
    friend_id INT NOT NULL,
    friend_type ENUM('WORK', 'SCHOOL', 'RELATIVE', 'FRIEND', 'ACQUAINTANCE', 'OTHER') NOT NULL,/*change in data dictionary*/
    PRIMARY KEY(user_id, friend_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(friend_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE images(
    image_id INT NOT NULL AUTO_INCREMENT, /*change in data dictionary*/
    post_id INT NOT NULL,
    /*caption VARCHAR(30),*/
    file_name VARCHAR(256) NOT NULL, /*change in data dictionary*/
    /*time_stamp DATETIME NOT NULL,*/ /*change in data dictionary*/
    PRIMARY KEY(image_id),
    FOREIGN KEY(post_id) REFERENCES post(post_id) ON DELETE CASCADE ON UPDATE CASCADE 
);

CREATE TABLE create_group(
    group_id INT NOT NULL AUTO_INCREMENT, /*change in data dictionary*/
    user_id INT NOT NULL,
    PRIMARY KEY(group_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE join_group(
    user_id INT NOT NULL,
    group_id INT NOT NULL,
    mem_role ENUM('MEMBER','CONTENT EDITOR') NOT NULL,/*change in data dictionary */
    PRIMARY KEY(user_id, group_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(group_id) REFERENCES user_group(group_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE create_post(
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    PRIMARY KEY(user_id, post_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(post_id) REFERENCES post(post_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE create_comment(
    user_id INT NOT NULL,
    comment_id INT NOT NULL,
    PRIMARY KEY(user_id, comment_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(comment_id) REFERENCES comment(comment_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE contains(
    post_id INT NOT NULL,
    image_id INT NOT NULL,
    PRIMARY KEY(post_id, image_id),
    FOREIGN KEY(post_id) REFERENCES post(post_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(image_id) REFERENCES images(image_id) ON DELETE CASCADE ON UPDATE CASCADE
);

DELIMITER $$
    CREATE TRIGGER Load_User_Profile
    AFTER INSERT ON csv_users
    FOR EACH ROW
    BEGIN
    INSERT INTO user(username, email_address, user_password, datejoined)
    VALUES
    (NEW.username, NEW.email, SHA2(NEW.password, 256), CURDATE());

    INSERT INTO profile(user_id, firstname, lastname, gender)
    VALUES
    (NEW.id, NEW.firstname, NEW.lastname, NEW.gender);
    END $$
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE loginUser(IN user_name VARCHAR(100), IN pass_word VARCHAR(256))
    BEGIN
    IF EXISTS(SELECT * FROM user WHERE username = user_name OR email_address = user_name) THEN
        IF EXISTS(SELECT user_id FROM user WHERE user_password = SHA2(pass_word, 256) AND (username = user_name OR email_address = user_name)) THEN
            SELECT 'Login successful';
        ELSE
            SELECT 'Password incorrect';
        END IF;
    ELSE
        SELECT 'User does not exist';
    END IF;
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE getUserID(IN in_username VARCHAR(100), IN in_email_address VARCHAR(70))
    BEGIN
    SELECT user_id FROM user WHERE username = in_username OR email_address = in_email_address;
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE createPost(IN in_user_id INT, IN in_content VARCHAR(300), IN in_post_location VARCHAR(70))
    BEGIN
    INSERT INTO post(content, time_stamp, post_location) 
    VALUES (in_content, SYSDATE(), in_post_location);
    
    INSERT INTO create_post 
    VALUES
    /*THE SELECT STATEMENT BELOW FINDS LAST POST ID CREATED AND INSERTS IT INTO THE SECOND PARAMETER*/
    (in_user_id, (SELECT post_id FROM post ORDER BY post_id DESC LIMIT 1));
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE createImagePost(IN in_user_id INT, IN in_content VARCHAR(300), IN in_post_location VARCHAR(70), IN in_file_name VARCHAR(256))
    BEGIN
    CALL createPost(in_user_id, in_content, in_post_location);
    
    INSERT INTO images(post_id, file_name)
    /*THE SELECT STATEMENT BELOW FINDS LAST POST ID CREATED AND INSERTS IT INTO THE FIRST PARAMETER*/
    VALUES ((SELECT post_id FROM post ORDER BY post_id DESC LIMIT 1), in_file_name);

    INSERT INTO contains
    VALUES
    /*IMMEDIATELY BELOW SELECTS THE LAST CREATED POST ID*/       /*IMMEDIATELY BELOW SELECTS THE LAST CREATEd IMAGE ID*/
    ((SELECT post_id FROM post ORDER BY post_id DESC LIMIT 1), (SELECT image_id FROM images ORDER BY image_id DESC LIMIT 1));
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE createComment(IN in_user_id INT, IN in_post_id INT, IN in_comm_text VARCHAR(300), IN in_c_location VARCHAR(70))
    BEGIN
    INSERT INTO comment(post_id, comm_text, time_stamp, c_location) 
    VALUES (in_post_id, in_comm_text, SYSDATE(), in_c_location);
    
    INSERT INTO create_comment
    VALUES
    /*THE SELECT STATEMENT BELOW FINDS LAST COMMENT ID CREATED AND INSERTS IT INTO THE SECOND PARAMETER*/
    (in_user_id, (SELECT comment_id FROM comment ORDER BY comment_id DESC LIMIT 1));
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE createGroup (IN in_user_id INT, IN in_group_name VARCHAR(90), IN in_group_description VARCHAR(300))
    BEGIN
    INSERT INTO user_group(group_name, group_description) 
    VALUES (in_group_name, in_group_description);
    
    INSERT INTO create_group 
    VALUES
    /*THE SELECT STATEMENT BELOW FINDS LAST GROUP ID CREATED AND INSERTS IT INTO THE FIRST PARAMETER*/
    ((SELECT group_id FROM user_group ORDER BY group_id DESC LIMIT 1), in_user_id);

    /*INSERT INTO join_group 
    VALUES*/
    /*THE SELECT STATEMENT BELOW FINDS LAST GROUP ID CREATED AND INSERTS IT INTO THE SECOND PARAMETER*/
    /*(in_user_id, (SELECT group_id FROM user_group ORDER BY group_id DESC LIMIT 1), 'CONTENT EDITOR');*/
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE joinGroup (IN in_user_id INT, IN in_group_id INT, in_mem_role VARCHAR(20))
    BEGIN
    INSERT INTO join_group 
    VALUES
    (in_user_id, in_group_id, in_mem_role);
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE showUserPosts(IN in_user_id INT)
    BEGIN
    SELECT post.post_id, post.content, post.time_stamp, post.post_location FROM post 
    JOIN create_post 
    ON post.post_id = create_post.post_id 
    JOIN user 
    ON user.user_id = create_post.user_id
    WHERE user.user_id = in_user_id;
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE showUserImages(IN in_user_id INT)
    BEGIN
    SELECT post.post_id, post.content, images.file_name, post.time_stamp, post.post_location FROM post 
    JOIN create_post 
    ON post.post_id = create_post.post_id 
    JOIN user 
    ON user.user_id = create_post.user_id
    JOIN contains
    ON contains.post_id = post.post_id
    JOIN images 
    ON images.image_id = contains.image_id
    WHERE user.user_id = in_user_id;
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE showUserComments(IN in_user_id INT)
    BEGIN
    SELECT comment.comment_id, comment.comm_text, comment.time_stamp, comment.c_location FROM comment 
    JOIN create_comment 
    ON comment.comment_id = create_comment.comment_id 
    JOIN user 
    ON user.user_id = create_comment.user_id
    WHERE user.user_id = in_user_id;
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE addFriend(IN in_user_id INT, IN in_friend_id INT, IN in_friend_type VARCHAR(15))
    BEGIN
    INSERT INTO friends(user_id, friend_id, friend_type)
    VALUES
    (in_user_id, in_friend_id, in_friend_type);
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE showUserFriends(IN in_user_id INT)
    BEGIN
    SELECT friend_id, friend_type FROM friends
    WHERE user_id = in_user_id;
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE showUserGroups(IN in_user_id INT)
    BEGIN
    
    /*SET @CreatorStr = 'CREATOR'; /*User-created variable to store string to be used in subquery below - to avoid string syntax issues*/

    /*using dynamic SQL to create views
    /*add views to data dictionary
    EXEC(' 
        CREATE VIEW composite_creator_group AS 
            (SELECT user_id, group_id, @CreatorStr AS mem_role 
                FROM create_group);
    ');

    EXEC('
        CREATE VIEW all_group_entries AS
            (SELECT * FROM join_group
                UNION
                    SELECT * FROM composite_creator_group
            );
    ');

    SELECT * FROM all_group_entries WHERE user_id = in_user_id;*/ /*ANOTHER APPROACH BELOW*/
    SELECT * FROM join_group
    WHERE join_group.user_id = in_user_id
    UNION
    SELECT user_id, group_id, 'CREATOR' AS mem_role FROM create_group
    WHERE create_group.user_id = in_user_id;

    END //
DELIMITER ;


DELIMITER //
    CREATE PROCEDURE postCreator(IN postID INT)
    BEGIN
    SELECT user_id FROM create_post WHERE post_id = postID;
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE commentCreator(IN commID INT)
    BEGIN
    SELECT user_id FROM create_comment WHERE comment_id = commID;
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE groupCreator(IN groupID INT)
    BEGIN
    SELECT user_id FROM create_group WHERE group_id = groupID;
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE getPostComments(IN in_post_id INT)
    BEGIN
    SELECT comment_id, comm_text, time_stamp, c_location FROM comment
    WHERE post_id = in_post_id;
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE numFriends(IN userID INT)
    BEGIN
    SELECT count(friend_id) FROM friends WHERE user_id = userID;
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE numTypeFriends(IN userID INT, IN friendType VARCHAR(30))
    BEGIN
    IF (friendType = "WORK") THEN
        SELECT count(friend_id) FROM friends WHERE user_id = userID and friend_type = "WORK";
    ELSE 
        IF (friendType = "SCHOOL") THEN
            SELECT count(friend_id) FROM friends WHERE user_id = userID and friend_type = "SCHOOL";
        ELSE
            IF (friendType = "RELATIVE") THEN
                SELECT count(friend_id) FROM friends WHERE user_id = userID and friend_type = "RELATIVE";
            ELSE
                IF (friendType = "FRIEND") THEN
                    SELECT count(friend_id) FROM friends WHERE user_id = userID and friend_type = "FRIEND";
                ELSE
                    IF (friendType = "ACQUAINTANCE") THEN
                        SELECT count(friend_id) FROM friends WHERE user_id = userID and friend_type = "ACQUAINTANCE";
                    ELSE
                        SELECT count(friend_id) FROM friends WHERE user_id = userID and friend_type = "OTHER";
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE listFriendIDs(IN userID INT)
    BEGIN
    SELECT friend_id FROM friends WHERE user_id = userID;
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE listTypeFriendIDs(IN userID INT, IN friendType VARCHAR(30))
    BEGIN
    IF (friendType = "WORK") THEN
        SELECT friend_id FROM friends WHERE user_id = userID and friend_type = "WORK";
    ELSE 
        IF (friendType = "SCHOOL") THEN
            SELECT friend_id FROM friends WHERE user_id = userID and friend_type = "SCHOOL";
        ELSE
            IF (friendType = "RELATIVE") THEN
                SELECT friend_id FROM friends WHERE user_id = userID and friend_type = "RELATIVE";
            ELSE
                IF (friendType = "FRIEND") THEN
                    SELECT friend_id FROM friends WHERE user_id = userID and friend_type = "FRIEND";
                ELSE
                    IF (friendType = "ACQUAINTANCE") THEN
                        SELECT friend_id FROM friends WHERE user_id = userID and friend_type = "ACQUAINTANCE";
                    ELSE
                        SELECT friend_id FROM friends WHERE user_id = userID and friend_type = "OTHER";
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE signUp(IN in_username VARCHAR(100), IN in_email_address VARCHAR(70), IN in_password VARCHAR(256), IN in_first_name VARCHAR(75), IN in_last_name VARCHAR(75), IN in_profile_img VARCHAR(100), IN in_gender VARCHAR(10))
    BEGIN
    INSERT INTO user(username, email_address, user_password, datejoined)
    VALUES
    (in_username, in_email_address, SHA2(in_password, 256), CURDATE());

    INSERT INTO profile(user_id, firstname, lastname, gender, profile_img)
    VALUES
    /*THE SELECT STATEMENT BELOW SELECTS THE USER ID OF THE LAST CREATED USER*/
    ((SELECT user_id FROM user ORDER BY user_id DESC LIMIT 1), in_first_name, in_last_name, in_gender, in_profile_img);
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE userDetails(IN in_user_id INT)
    BEGIN

    SELECT user.username, user.email_address, user.datejoined, profile.firstname, profile.lastname, profile.profile_img, profile.friends, profile.biography, profile.gender
    FROM user 
    JOIN profile
    ON user.user_id = profile.user_id
    WHERE user.user_id = in_user_id;

    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE updateProfilePicture(IN in_user_id INT, IN in_profile_img VARCHAR(100))
    BEGIN
    UPDATE profile
    SET profile_img = in_profile_img
    WHERE profile.user_id = in_user_id;
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE updateBiography(IN in_user_id INT, IN in_biography VARCHAR(300))
    BEGIN
    UPDATE profile
    SET biography = in_biography
    WHERE profile.user_id = in_user_id;
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE changePassword(IN in_user_id INT, IN in_password VARCHAR(256))
    BEGIN
    UPDATE user
    SET user_password = SHA2(in_password, 256)
    WHERE user.user_id = in_user_id;
    END //
DELIMITER ;

DELIMITER $$
    CREATE TRIGGER updateFriendsAmount
    AFTER INSERT ON friends
    FOR EACH ROW

    UPDATE profile 
    SET profile.friends = (
        SELECT COUNT(friends.friend_id) FROM friends
        WHERE friends.user_id = NEW.user_id
        )
    WHERE profile.user_id = NEW.user_id;

    END $$
DELIMITER ;