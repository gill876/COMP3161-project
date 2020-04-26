/*COMP3161 PROJECT*/
DROP TABLE IF EXISTS profile;
DROP TABLE IF EXISTS user;
/*SHOW WARNINGS;*/

CREATE TABLE user(
    user_id INT NOT NULL,
    username VARCHAR(100) NOT NULL,
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
    username VARCHAR(100) NOT NULL,
    profile_img VARCHAR(100) NOT NULL,
    friends INT DEFAULT 0 NOT NULL,
    biography VARCHAR(300) DEFAULT "Hey there! I'm using MyBook" NOT NULL,
    gender ENUM('MALE', 'FEMALE', 'OTHER') NOT NULL,
    PRIMARY KEY(profile_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);