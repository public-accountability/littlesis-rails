-- IMPORTANT!
-- This script deletes user data and is only to be run locally in development

UPDATE users
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
    email = CONCAT('user', id, '@email.com'),
    username = CONCAT('user_', id);

-- This sets the systems user's password to be 'password'
UPDATE users
SET encrypted_password = '$2a$10$Q2tSw2llUagw1KRNTtLD4.JiYgFA.9pxgV5aPOs/IxFsddZGa8jgO'
WHERE id = 1;



UPDATE user_profiles
SET name_first = CONCAT('firstname', id ),
    name_last = CONCAT('lastname', id ),
    reason = 'truth is always in harmony with herself',
    location = 'earth',
    created_at = CURRENT_TIMESTAMP,
    updated_at = CURRENT_TIMESTAMP;
