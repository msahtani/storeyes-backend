-- User preferences (per user, e.g. personnel charge last period)
-- user_id = Keycloak subject (JWT sub)
CREATE TABLE IF NOT EXISTS user_preferences (
    user_id VARCHAR(255) NOT NULL,
    preference_key VARCHAR(128) NOT NULL,
    preference_value VARCHAR(512),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, preference_key)
);

CREATE INDEX IF NOT EXISTS idx_user_preferences_user_id ON user_preferences(user_id);
COMMENT ON TABLE user_preferences IS 'User preferences keyed by Keycloak user id';
