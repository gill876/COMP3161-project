/*COMP3161 PROJECT*/ /*PLEASE VERIFY WITH DOCS*/
DROP TABLE IF EXISTS contains;
DROP TABLE IF EXISTS create_post;
DROP TABLE IF EXISTS create_comment;
DROP TABLE IF EXISTS join_group;
DROP TABLE IF EXISTS create_group;
DROP TABLE IF EXISTS group_post;
DROP TABLE IF EXISTS userProfile;
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
DROP TRIGGER IF EXISTS updateFriendsAmount; /*UPDATE THE # OF FRIENDS OF A USER WHEN A FRIEND IS ADDED*/
/*SHOW WARNINGS;*/

DROP PROCEDURE IF EXISTS loginUser; /*PURPOSE:{LOGS A USER IN USING USERNAME OR EMAIL AND PASSWORD} INPUT:{username OR email address, password in plain text} OUTPUT:{'Login successful' OR 'Password incorrect' OR 'User does not exist'}*/
DROP PROCEDURE IF EXISTS getUserID; /*PURPOSE:{RETRIEVES USER ID FROM USERNAME OR EMAIL} INPUT:{username, email address} OUTPUT:{userID}*/
DROP PROCEDURE IF EXISTS createPost; /*PURPOSE:{CREATE POST} INPUT:{userID, content in plain text, location} OUTPUT:{NO OUTPUT}*/
DROP PROCEDURE IF EXISTS createGroupPost; /*PURPOSE:{CREATE GROUP POST} INPUT:{userID, content in plain text, location, groupID} OUTPUT:{NO OUTPUT}*/
DROP PROCEDURE IF EXISTS getGroupPosts; /*PURPOSE:{RETRIEVES POST CREATED BY GROUP} INPUT:{groupID} OUTPUT:{postID, content, time_stamp, location}*/
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
DROP PROCEDURE IF EXISTS signUp; /*PURPOSE:{SIGNS UP A USER} INPUT:{username, email, password in plain text, first name, last name, profile image with path, gender['MALE', 'FEMALE', 'NON-BINARY', 'OTHER']} OUTPUT:{NO OUTPUT}*/
DROP PROCEDURE IF EXISTS userDetails; /*PURPOSE:{RETRIEVES USER DETAILS FROM USER ID} INPUT:{userID} OUTPUT:{TABLE WITH: username, email, date_joined, first_name, last_name, profile_image, #_of_friends, biography, gender}*/
DROP PROCEDURE IF EXISTS updateProfilePicture; /*PURPOSE:{UPDATES PROFILE PICTURE OF USER} INPUT:{userID, profile images with path} OUTPUT:{NO OUTPUT}*/
DROP PROCEDURE IF EXISTS updateBiography; /*PURPOSE:{UPDATES USER BIOGRAPHY} INPUT:{userID, biography} OUTPUT:{NO OUTPUT}*/
DROP PROCEDURE IF EXISTS changePassword; /*PURPOSE:{CHANGES USER PASSWORD} INPUT:{userID, password in plain text} OUTPUT:{NO OUTPUT}*/

/*TODO - Add procedure and index descriptions*/
DROP PROCEDURE IF EXISTS adminUserBio;
DROP PROCEDURE IF EXISTS adminUserPostTotals;
DROP PROCEDURE IF EXISTS adminUserFriendTotals;
DROP PROCEDURE IF EXISTS adminUserGroupTotals;
DROP PROCEDURE IF EXISTS adminUserCommentTotals;
DROP PROCEDURE IF EXISTS adminGroupName;
DROP PROCEDURE IF EXISTS adminGroupCreatorByUserId;
DROP PROCEDURE IF EXISTS getGrpTotalMembers;
DROP PROCEDURE IF EXISTS adminGetUserBio;
DROP PROCEDURE IF EXISTS getUserTotalPosts;
DROP PROCEDURE IF EXISTS getUserTotalComments;
DROP PROCEDURE IF EXISTS getUserTotalFriends;
DROP PROCEDURE IF EXISTS getUserTotalGroups;
DROP PROCEDURE IF EXISTS getGroupId;
DROP PROCEDURE IF EXISTS adminSearchGroup;
DROP PROCEDURE IF EXISTS adminGetUserBio;
DROP PROCEDURE IF EXISTS groupTotalMembers;
DROP PROCEDURE IF EXISTS groupTotalPosts;
DROP PROCEDURE IF EXISTS adminGetUserFriends;
DROP PROCEDURE IF EXISTS getUserTotalGroupPosts;
DROP PROCEDURE IF EXISTS adminUserGroupsInfo;
DROP PROCEDURE IF EXISTS adminUserGroups;
DROP PROCEDURE IF EXISTS adminGetUserPostImageDetails;
DROP PROCEDURE IF EXISTS adminGetUserGroupPostDetails;
DROP PROCEDURE IF EXISTS adminGetUserPostDetails;
DROP PROCEDURE IF EXISTS adminGetUserPostDetails;
DROP PROCEDURE IF EXISTS adminGetUserCommentDetails;
DROP PROCEDURE IF EXISTS addPost; 
DROP PROCEDURE IF EXISTS createPost; 


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
    firstname VARCHAR(75) NOT NULL,
    lastname VARCHAR(75) NOT NULL,
    profile_img VARCHAR(100) DEFAULT 'GENERIC' NOT NULL,
    friends INT DEFAULT 0 NOT NULL,
    biography VARCHAR(300) DEFAULT "Hey there! I'm using MyBook" NOT NULL, 
    gender VARCHAR(10) NOT NULL,
    PRIMARY KEY(profile_id)
);

CREATE TABLE userProfile(
    profile_id INT NOT NULL,
    user_id INT DEFAULT 0 NOT NULL,
    PRIMARY KEY(profile_id, user_id),
    FOREIGN KEY(profile_id) REFERENCES profile(profile_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE post(
    post_id INT NOT NULL AUTO_INCREMENT,
    content VARCHAR(300) NOT NULL, 
    time_stamp DATETIME NOT NULL,
    post_location VARCHAR(70) DEFAULT "Somewhere on Earth" NOT NULL,
    PRIMARY KEY(post_id)
);

CREATE TABLE user_group( 
    group_id INT NOT NULL AUTO_INCREMENT, 
    group_name VARCHAR(90) NOT NULL,
    group_description VARCHAR(300) NOT NULL, 
    PRIMARY KEY(group_id)
);

CREATE TABLE comment(
    comment_id INT NOT NULL AUTO_INCREMENT, 
    post_id INT NOT NULL,
    comm_text VARCHAR(300),
    time_stamp DATETIME NOT NULL,
    c_location VARCHAR(70) DEFAULT "Somewhere on Earth" NOT NULL,
    PRIMARY KEY(comment_id),
    FOREIGN KEY(post_id) REFERENCES post(post_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE friends(
    user_id INT NOT NULL,
    friend_id INT NOT NULL,
    friend_type ENUM('WORK', 'SCHOOL', 'RELATIVE', 'FRIEND', 'ACQUAINTANCE', 'OTHER') NOT NULL,
    PRIMARY KEY(user_id, friend_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(friend_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE images(
    image_id INT NOT NULL AUTO_INCREMENT, 
    post_id INT NOT NULL,
    file_name VARCHAR(256) NOT NULL, 
    PRIMARY KEY(image_id),
    FOREIGN KEY(post_id) REFERENCES post(post_id) ON DELETE CASCADE ON UPDATE CASCADE 
);

CREATE TABLE create_group(
    group_id INT NOT NULL AUTO_INCREMENT, 
    user_id INT NOT NULL,
    time_stamp DATETIME NOT NULL, /*change in data dictionary*/
    PRIMARY KEY(group_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE join_group(
    user_id INT NOT NULL,
    group_id INT NOT NULL,
    mem_role ENUM('MEMBER','CONTENT EDITOR') NOT NULL,
    PRIMARY KEY(user_id, group_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(group_id) REFERENCES user_group(group_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE group_post( /*change in data dictionary*/
    group_id INT NOT NULL,
    post_id INT NOT NULL,
    PRIMARY KEY(group_id, post_id),
    FOREIGN KEY(group_id) REFERENCES user_group(group_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(post_id) REFERENCES post(post_id) ON DELETE CASCADE ON UPDATE CASCADE 
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

/* INDEXES - USED TO OPTIMIZE DB SEARCH TIMES*/
DROP INDEX u_username ON user;
DROP INDEX u_user_id ON user;
DROP INDEX profile_id ON profile;
DROP INDEX up_profile_id ON userProfile;
DROP INDEX post_id ON post;
DROP INDEX comment_id ON comment;
DROP INDEX f_user_id ON friends;
DROP INDEX grp_user_id ON join_group;
DROP INDEX grp_grp_id ON join_group;
DROP INDEX fullname ON profile;

CREATE INDEX u_username ON user(username);
CREATE INDEX u_user_id ON user(user_id);
CREATE INDEX profile_id ON profile(profile_id);
CREATE INDEX up_profile_id ON userProfile(profile_id);
CREATE INDEX post_id ON post(post_id);
CREATE INDEX comment_id ON comment(comment_id);
CREATE INDEX f_user_id ON friends(user_id);
CREATE INDEX grp_user_id ON join_group(user_id);
CREATE INDEX grp_grp_id ON join_group(user_id);
create index fullname on profile(firstname, lastname);


/* TRIGGERS and STORED PROCEDURES */

DELIMITER $$
    CREATE TRIGGER Load_User_Profile
    AFTER INSERT ON csv_users
    FOR EACH ROW
    BEGIN
    INSERT INTO user(username, email_address, user_password, datejoined)
    VALUES
    (NEW.username, NEW.email, SHA2(NEW.password, 256), CURDATE());

    INSERT INTO profile(firstname, lastname, gender)
    VALUES
    (NEW.firstname, NEW.lastname, NEW.gender);

    INSERT INTO userProfile(profile_id, user_id)
    VALUES
    /*THE SELECT STATEMENTS BELOW DETERMINE THE LAST ENTRY # FROM BOTH PROFILE AND USER TABLE AND INSERTS IT INTO THE USERPROFILE TABLE TO LINK PROFILE WITH USER*/
    ((SELECT profile_id FROM profile ORDER BY profile_id DESC LIMIT 1), (SELECT user_id FROM user ORDER BY user_id DESC LIMIT 1));
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
    VALUES (in_content, CURDATE(), in_post_location);
    
    INSERT INTO create_post 
    VALUES
    /*THE SELECT STATEMENT BELOW FINDS LAST POST ID CREATED AND INSERTS IT INTO THE SECOND PARAMETER*/
    (in_user_id, (SELECT post_id FROM post ORDER BY post_id DESC LIMIT 1));
    END //
DELIMITER ;


DELIMITER //
    CREATE PROCEDURE createGroupPost(IN in_user_id INT, IN in_content VARCHAR(300), IN in_post_location VARCHAR(70), IN in_group_id INT)
    BEGIN
    INSERT INTO post(content, time_stamp, post_location) 
    VALUES (in_content, SYSDATE(), in_post_location);
    
    INSERT INTO create_post 
    VALUES
    /*THE SELECT STATEMENT BELOW FINDS LAST POST ID CREATED AND INSERTS IT INTO THE SECOND PARAMETER*/
    (in_user_id, (SELECT post_id FROM post ORDER BY post_id DESC LIMIT 1));

    INSERT INTO group_post
    VALUES
    /*THE SELECT STATEMENT BELOW FINDS LAST POST ID CREATED AND INSERTS IT INTO THE SECOND PARAMETER*/
    (in_group_id, (SELECT post_id FROM post ORDER BY post_id DESC LIMIT 1));    
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE getGroupPosts(IN in_group_id INT)
    BEGIN
    SELECT post.post_id, post.content, post.time_stamp, post.post_location 
    FROM post 
    JOIN group_post
    ON post.post_id = group_post.post_id
    WHERE group_post.group_id = in_group_id;
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
    VALUES (in_post_id, in_comm_text, CURDATE(), in_c_location);
    
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
    ((SELECT group_id FROM user_group ORDER BY group_id DESC LIMIT 1), in_user_id, SYSDATE());

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
    
    SELECT * FROM join_group
    WHERE join_group.user_id = in_user_id
    UNION
    SELECT user_id, group_id, 'CREATOR' AS mem_role FROM create_group
    WHERE create_group.user_id = in_user_id;

    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE showUserGroups(IN in_user_id INT)
    BEGIN
    
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

    INSERT INTO profile(firstname, lastname, gender, profile_img)
    VALUES
    /*THE SELECT STATEMENT BELOW SELECTS THE USER ID OF THE LAST CREATED USER*/
    (in_first_name, in_last_name, in_gender, in_profile_img);

    INSERT INTO userProfile(profile_id, user_id)
    VALUES
    /*THE SELECT STATEMENTS BELOW FIND THE LAST POST ID AND USER ID CREATED AND INSERT THEM INTO THE RESPECTIVE PARAMETERS*/
    ((SELECT profile_id FROM profile ORDER BY profile_id DESC LIMIT 1), (SELECT user_id FROM user ORDER BY user_id DESC LIMIT 1));
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE userDetails(IN in_user_id INT)
    BEGIN

    SELECT user.username, user.email_address, user.datejoined, profile.firstname, profile.lastname, profile.profile_img, profile.friends, profile.biography, profile.gender
    FROM user 
    JOIN profile
    JOIN userProfile
    ON user.user_id = userProfile.user_id
    AND profile.profile_id = userProfile.profile_id
    WHERE user.user_id = in_user_id;

    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE updateProfilePicture(IN in_user_id INT, IN in_profile_img VARCHAR(100))
    BEGIN
    UPDATE profile
    SET profile_img = in_profile_img
    WHERE profile.profile_id = (SELECT profile_id from userProfile where userProfile.user_id = in_user_id);
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE updateBiography(IN in_user_id INT, IN in_biography VARCHAR(300))
    BEGIN
    UPDATE profile
    SET biography = in_biography
    WHERE profile.profile_id = (SELECT profile_id from userProfile where userProfile.user_id = in_user_id);
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
    BEGIN
    UPDATE profile 
    SET profile.friends = (
        SELECT COUNT(friends.friend_id) FROM friends
        WHERE friends.user_id = NEW.user_id
        )
    WHERE profile.profile_id = (SELECT profile_id from userProfile where userProfile.user_id = NEW.user_id);
    END $$
DELIMITER ;*/

/* ADDITIONAL PROCEDURES */
DELIMITER //
    CREATE PROCEDURE adminUserBio()
    BEGIN

    SELECT user.username, profile.firstname, profile.lastname, profile.gender, profile.friends
    FROM user
    JOIN profile
    JOIN userProfile
    ON user.user_id = userProfile.user_id
    AND profile.profile_id = userProfile.profile_id
    ORDER BY user.user_id;

    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE adminGetUserBio(IN in_name VARCHAR(151))
    BEGIN

    SELECT user.user_id, user.username, profile.firstname, profile.lastname, profile.gender
    FROM user
    JOIN profile
    JOIN userProfile
    ON user.user_id = userProfile.user_id
    AND profile.profile_id = userProfile.profile_id
    WHERE profile.firstname LIKE CONCAT(in_name, '%')
    OR profile.lastname LIKE CONCAT(in_name, '%')
    ORDER BY user.user_id;

    END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE adminGetUserBioByUname(IN in_user_name VARCHAR(151))
BEGIN

    SELECT user.user_id, user.username, profile.firstname, profile.lastname, profile.gender, profile.profile_img 
    FROM user
    JOIN profile
    JOIN userProfile
    ON user.user_id = userProfile.user_id
    AND profile.profile_id = userProfile.profile_id 
    WHERE user.username = in_user_name
    LIMIT 1;

END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE adminSearchGroup(IN in_name VARCHAR(90))
    BEGIN

    SELECT user_group.group_id, user_group.group_name, user_group.group_description
    FROM user_group
    WHERE user_group.group_name LIKE CONCAT(in_name, '%')
    ORDER BY user_group.group_id;

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

DELIMITER //
    CREATE PROCEDURE adminGroupName()
    BEGIN

    SELECT user_group.group_name
    FROM user_group
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
    ORDER BY create_group.group_id;

    END//
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE getGrpTotalMembers()
    BEGIN

    SELECT COUNT(join_group.group_id)
    FROM (join_group)
    GROUP BY join_group.group_id 
    ORDER BY join_group.group_id;

    END//
DELIMITER ;


DELIMITER //
    CREATE PROCEDURE getUserTotalPosts(IN in_user_id INT)
    BEGIN

        SELECT COUNT(create_post.user_id)
        FROM (create_post)
        WHERE create_post.user_id  = in_user_id
        AND create_post.post_id
        NOT IN (
            SELECT group_post.post_id
            FROM group_post
        );
    
    END//
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE getUserTotalComments(IN in_user_id INT)
    BEGIN

        SELECT COUNT(create_comment.user_id)
        FROM (create_comment)
        WHERE create_comment.user_id  = in_user_id;

    END//
DELIMITER ;


DELIMITER //
    CREATE PROCEDURE getUserTotalFriends(IN in_user_id INT)
    BEGIN

        SELECT COUNT(friends.user_id)
        FROM (friends)
        WHERE friends.user_id  = in_user_id;

    END//
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE getUserTotalGroups(IN in_user_id INT)
    BEGIN

        SELECT COUNT(join_group.user_id)
        FROM (join_group)
        WHERE join_group.user_id  = in_user_id;

    END//
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE getGroupId(IN in_group_name VARCHAR(90))
    BEGIN
    
    SELECT group_id FROM user_group
    WHERE group_name = in_group_name
    LIMIT 1;

    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE groupTotalMembers(IN in_group_id INT)
    BEGIN
        SELECT COUNT(join_group.group_id)
        FROM join_group
        WHERE join_group.group_id = in_group_id
        LIMIT 1;
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE groupTotalPosts(IN in_group_id INT)
    BEGIN
        SELECT COUNT(group_post.group_id)
        FROM group_post
        WHERE group_post.group_id = in_group_id;
    END //
DELIMITER ;

DELIMITER //
    CREATE PROCEDURE adminGetUserFriends(IN in_user_id INT)
    BEGIN
        SELECT user.username, CONCAT(`firstname`, ' ', `lastname`), friends.friend_id, friends.friend_type
        FROM friends
        JOIN user 
        JOIN userProfile
        JOIN profile
        ON friends.user_id = user.user_id
        AND user.user_id = userProfile.user_id
        AND userProfile.profile_id = profile.profile_id
        WHERE user.user_id IN (
            SELECT friends.friend_id AS fId
            FROM friends
            WHERE friends.user_id = in_user_id
        );
    END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE getUserTotalGroupPosts(IN in_user_id INT)
BEGIN
    SELECT COUNT(create_post.post_id)
    FROM group_post
    JOIN create_post
    ON create_post.post_id = group_post.post_id
    WHERE create_post.user_id = in_user_id;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE adminUserGroupsInfo(IN in_user_id INT)
BEGIN
    SELECT user_group.group_name, CONCAT(`firstname`, ' ', `lastname`), DATE(time_stamp)
    FROM user_group
    JOIN create_group
    JOIN userProfile
    JOIN profile
    ON user_group.group_id = create_group.group_id 
    AND create_group.user_id = userProfile.user_id
    AND userProfile.profile_id = profile.profile_id
    WHERE userProfile.user_id IN (
        SELECT join_group.user_id
        FROM join_group
        WHERE join_group.user_id = in_user_id
    );
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE adminUserGroups(IN in_user_id INT)
BEGIN
    SELECT user_group.group_name
    FROM user_group
    JOIN create_group
    ON create_group.group_id = user_group.group_id
    WHERE create_group.user_id = in_user_id;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE adminGetUserPostDetails(IN user_id_in INT)
BEGIN
SELECT profile.profile_img, CONCAT(`firstname`, ' ', `lastname`), post.post_id, post.post_location, post.time_stamp, post.content FROM profile JOIN userProfile JOIN create_post JOIN post ON profile.profile_id = userProfile.profile_id AND userProfile.user_id = create_post.user_id AND create_post.post_id = post.post_id WHERE create_post.user_id = user_id_in AND create_post.post_id NOT IN (SELECT group_post.post_id FROM group_post) ORDER BY post.time_stamp;
END //

CREATE PROCEDURE adminGetUserPostImageDetails(in user_id_in INT)
BEGIN
SELECT post.post_id, images.file_name
FROM create_post
JOIN post
JOIN contains
JOIN images
ON create_post.post_id = post.post_id
AND post.post_id = contains.post_id
AND contains.image_id = images.image_id
WHERE create_post.user_id = user_id_in;
END //

CREATE PROCEDURE adminGetUserGroupPostDetails(IN user_id_in INT)
BEGIN
    SELECT profile.profile_img,
    CONCAT(`firstname`, ' ', `lastname`),
    post.post_id, post.post_location,
    post.time_stamp, post.content
    FROM profile
    JOIN userProfile
    JOIN create_post
    JOIN post
    ON profile.profile_id = userProfile.profile_id
    AND userProfile.user_id = create_post.user_id
    AND create_post.post_id = post.post_id  
    WHERE create_post.user_id = user_id_in
    AND create_post.post_id
    NOT IN (
        SELECT group_post.post_id
        FROM group_post
        )
    ORDER BY post.time_stamp;
END //

CREATE PROCEDURE adminGetUserCommentDetails(IN user_id_in INT)
BEGIN
    SELECT comment.post_id, CONCAT(`firstname`, ' ', `lastname`), comment.comm_text, comment.time_stamp, comment.c_location
    FROM comment 
    JOIN create_comment
    JOIN userProfile 
    JOIN profile
    ON comment.comment_id = create_comment.comment_id
    AND create_comment.user_id = userProfile.user_id
    AND userProfile.profile_id = profile.profile_id
    WHERE create_comment.user_id = user_id_in 
    ORDER BY comment.time_stamp;
END //

CREATE PROCEDURE adminGetAllCommentDetails()
BEGIN
    SELECT comment.post_id, CONCAT(`firstname`, ' ', `lastname`), comment.comm_text, comment.time_stamp, comment.c_location
    FROM comment
        JOIN create_comment
        JOIN userProfile
        JOIN profile
        ON comment.comment_id = create_comment.comment_id
            AND create_comment.user_id = userProfile.user_id
            AND userProfile.profile_id = profile.profile_id  
    ORDER BY comment.time_stamp;
END //
DELIMITER ;