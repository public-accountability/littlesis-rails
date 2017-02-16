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

DROP TABLE IF EXISTS clean_sf_guard_user_profile;
CREATE TABLE clean_sf_guard_user_profile LIKE sf_guard_user_profile;
INSERT clean_sf_guard_user_profile SELECT * FROM sf_guard_user_profile;

UPDATE clean_sf_guard_user_profile
SET name_first = CONCAT('firstname', id ),
    name_last = CONCAT('lastname', id ),
    email = CONCAT('user_profile_', id, '@email.com'),
    reason = 'truth is always in harmony with herself',
    analyst_reason = '',
    invitation_code = NULL,
    public_name = CONCAT('profile', id),
    bio = 'anon',
    confirmation_code = NULL,
    filename = NULL,
    created_at = CURRENT_TIMESTAMP,
    updated_at = CURRENT_TIMESTAMP;
