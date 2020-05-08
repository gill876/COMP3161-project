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
DROP TABLE IF EXISTS csv_users;
/*SHOW WARNINGS;*/
DROP TRIGGER IF EXISTS Load_User_Profile; /*add trigger*/
/*SHOW WARNINGS;*/
DROP PROCEDURE IF EXISTS loginUser;
DROP PROCEDURE IF EXISTS getUserID;
DROP PROCEDURE IF EXISTS createPost;
DROP PROCEDURE IF EXISTS createImagePost;
DROP PROCEDURE IF EXISTS showUserPosts;
DROP PROCEDURE IF EXISTS showUserImages;
DROP PROCEDURE IF EXISTS postCreator;
DROP PROCEDURE IF EXISTS commentCreator;
DROP PROCEDURE IF EXISTS numFriends;
DROP PROCEDURE IF EXISTS numTypeFriends;
DROP PROCEDURE IF EXISTS listFriendIds;
DROP PROCEDURE IF EXISTS listTypeFriendIDs;

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
    post_location VARCHAR(70) NOT NULL,
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
    c_location VARCHAR(70) NOT NULL,
    PRIMARY KEY(comment_id, post_id),
    FOREIGN KEY(post_id) REFERENCES post(post_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE friends(
    user_id INT NOT NULL,
    friend_id INT NOT NULL,
    friend_type ENUM('WORK', 'SCHOOL', 'RELATIVE', 'OTHER') NOT NULL,/*change in data dictionary*/
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

/*DELIMITER //
    CREATE PROCEDURE addFriend(IN in_user_id INT, IN in_friend_id INT, IN in_friend_type VARCHAR(30))
    BEGIN
    INSERT INTO friends values (in_user_id, in_friend_id, in_friend_type);
    END //
DELIMITER ;*/

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
                SELECT count(friend_id) FROM friends WHERE user_id = userID and friend_type = "OTHER";
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
                SELECT friend_id FROM friends WHERE user_id = userID and friend_type = "OTHER";
            END IF;
        END IF;
    END IF;
    END //
DELIMITER ;