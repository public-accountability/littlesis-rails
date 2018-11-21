DROP TABLE IF EXISTS clean_users;
CREATE TABLE clean_users LIKE users;
INSERT clean_users SELECT * FROM users;

UPDATE clean_users 
SET encrypted_password = '',
    reset_password_token = NULL,
    reset_password_sent_at = NULL,
    remember_created_at = NULL,
    sign_in_count = 0,
    current_sign_in_at = NULL,
    last_sign_in_at = NULL,
    current_sign_in_ip = NULL,
    last_sign_in_ip = NULL,
    created_at = CURRENT_TIMESTAMP,
    updated_at = CURRENT_TIMESTAMP,
    remember_token = NULL,
    confirmation_token = NULL,
    confirmed_at = CURRENT_TIMESTAMP,
    confirmation_sent_at = CURRENT_TIMESTAMP,
    chatid = NULL,
    email = CONCAT('user', id, '@email.com'),
    username = CONCAT('user_', id);


-- This sets user #1 (system@littlesis.org) password to be 'password'
UPDATE clean_users
SET encrypted_password = '$2a$10$Q2tSw2llUagw1KRNTtLD4.JiYgFA.9pxgV5aPOs/IxFsddZGa8jgO'
WHERE id = 1 LIMIT 1;

DROP TABLE IF EXISTS clean_sf_guard_user;
CREATE TABLE clean_sf_guard_user LIKE sf_guard_user;
INSERT clean_sf_guard_user SELECT * FROM sf_guard_user;

UPDATE clean_sf_guard_user
SET username = CONCAT('sfuser', id, '@email.com'),
    salt = '',
    password = '',
    updated_at = CURRENT_TIMESTAMP,
    created_at = CURRENT_TIMESTAMP,
    last_login = CURRENT_TIMESTAMP;

DROP TABLE IF EXISTS clean_user_profiles;
CREATE TABLE clean_user_profiles LIKE user_profile;
INSERT clean_user_profiles SELECT * FROM user_profiles;

UPDATE clean_user_profiles
SET name_first = CONCAT('firstname', id ),
    name_last = CONCAT('lastname', id ),
    reason = 'truth is always in harmony with herself',
    location = 'earth',
    created_at = CURRENT_TIMESTAMP,
    updated_at = CURRENT_TIMESTAMP;
