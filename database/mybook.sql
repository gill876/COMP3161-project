/*COMP3161 PROJECT*/
DROP TABLE IF EXISTS contains;
DROP TABLE IF EXISTS create_post;
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
drop trigger IF EXISTS Load_User; /*add trigger*/
SHOW WARNINGS;

CREATE TABLE csv_users(
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
    user_id INT NOT NULL,
    firstname VARCHAR(75) NOT NULL,
    lastname VARCHAR(75) NOT NULL,
    username VARCHAR(100) NOT NULL UNIQUE,
    profile_img VARCHAR(100) NOT NULL,
    friends INT DEFAULT 0 NOT NULL,
    biography VARCHAR(300) DEFAULT "Hey there! I'm using MyBook" NOT NULL, /*change in data dictionary*/
    gender ENUM('MALE', 'FEMALE', 'OTHER') NOT NULL,
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
    comment VARCHAR(300),
    time_stamp DATETIME NOT NULL,
    c_location VARCHAR(70) NOT NULL,
    PRIMARY KEY(comment_id, post_id),
    FOREIGN KEY(post_id) REFERENCES post(post_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE friends(
    friend_id INT NOT NULL AUTO_INCREMENT, /*change in data dictionary*/
    user_id INT NOT NULL,
    friend_type ENUM('WORK', 'SCHOOL', 'RELATIVE', 'OTHER') NOT NULL,/*change in data dictionary*/
    PRIMARY KEY(friend_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE images(
    image_id INT NOT NULL AUTO_INCREMENT, /*change in data dictionary*/
    post_id INT NOT NULL,
    caption VARCHAR(30),
    file_name VARCHAR(256) NOT NULL, /*change in data dictionary*/
    time_stamp DATETIME NOT NULL, /*change in data dictionary*/
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

CREATE TABLE contains(
    post_id INT NOT NULL,
    image_id INT NOT NULL,
    PRIMARY KEY(post_id, image_id),
    FOREIGN KEY(post_id) REFERENCES post(post_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(image_id) REFERENCES images(image_id) ON DELETE CASCADE ON UPDATE CASCADE
);

DELIMITER $$
    CREATE TRIGGER Load_User
    AFTER INSERT ON csv_users
    FOR EACH ROW
    BEGIN
    INSERT INTO user(username, email_address, user_password, datejoined)
    /*SELECT * FROM 
    (SELECT (username, email, SHA2(password, 256), CURDATE())
    FROM csv_users) AS T;*/
    VALUES
    (NEW.username, NEW.email, SHA2(NEW.password, 256), CURDATE());
    END $$
DELIMITER ;