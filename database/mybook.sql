/*COMP3161 PROJECT*/
DROP TABLE IF EXISTS contains;
/*DROP TABLE IF EXISTS create_post;*/
DROP TABLE IF EXISTS join_group;
DROP TABLE IF EXISTS create_group;
DROP TABLE IF EXISTS profile;
DROP TABLE IF EXISTS comment;
DROP TABLE IF EXISTS user_group;
DROP TABLE IF EXISTS friends;
DROP TABLE IF EXISTS images;
DROP TABLE IF EXISTS post;
DROP TABLE IF EXISTS user;
/*SHOW WARNINGS;*/

CREATE TABLE user(
    user_id INT NOT NULL,
    username VARCHAR(100) NOT NULL UNIQUE,
    email_address VARCHAR(70) NOT NULL,
    password VARCHAR(256) NOT NULL,
    datejoined DATE NOT NULL,
    PRIMARY KEY(user_id)
);

CREATE TABLE profile(
    profile_id INT NOT NULL,
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
    user_id INT NOT NULL,
    content VARCHAR(300) NOT NULL, /*change in data dictionary*/
    timestamp DATETIME NOT NULL,
    location VARCHAR(70) NOT NULL,
    PRIMARY KEY(post_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE user_group( /*change in data dictionary*/
    group_id INT NOT NULL AUTO_INCREMENT, /*change in data dictionary*/
    group_name VARCHAR(90) NOT NULL,
    description VARCHAR(300) NOT NULL, /*change in data dictionary*/
    PRIMARY KEY(group_id)
);

CREATE TABLE comment(
    comment_id INT NOT NULL AUTO_INCREMENT, /*change in data dictionary*/
    post_id INT NOT NULL,
    text VARCHAR(300),
    timestamp DATETIME NOT NULL,
    location VARCHAR(70) NOT NULL,
    PRIMARY KEY(comment_id, post_id),
    FOREIGN KEY(post_id) REFERENCES post(post_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE friends(
    friend_id INT NOT NULL AUTO_INCREMENT, /*change in data dictionary*/
    user_id INT NOT NULL,
    type ENUM('WORK', 'SCHOOL', 'RELATIVE', 'OTHER') NOT NULL,/*change in data dictionary*/
    PRIMARY KEY(friend_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE images(
    image_id INT NOT NULL AUTO_INCREMENT, /*change in data dictionary*/
    post_id INT NOT NULL,
    caption VARCHAR(30),
    file_name VARCHAR(256) NOT NULL, /*change in data dictionary*/
    timestamp DATETIME NOT NULL, /*change in data dictionary*/
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
    PRIMARY KEY(user_id, group_id)
);

/*CREATE TABLE create_post(
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    PRIMARY KEY(user_id, post_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(post_id) REFERENCES post(post_id) ON DELETE CASCADE ON UPDATE CASCADE
);*/

CREATE TABLE contains(
    post_id INT NOT NULL,
    image_id INT NOT NULL,
    PRIMARY KEY(post_id, image_id),
    FOREIGN KEY(post_id) REFERENCES post(post_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(image_id) REFERENCES images(image_id) ON DELETE CASCADE ON UPDATE CASCADE
);