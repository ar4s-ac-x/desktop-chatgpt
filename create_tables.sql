CREATE TABLE IF NOT EXISTS config (
    key TEXT NOT NULL PRIMARY KEY,
    value ANY
) STRICT;

CREATE TABLE IF NOT EXISTS message (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    parent INTEGER REFERENCES message(id) ON DELETE CASCADE,
    role TEXT NOT NULL,
    status INTEGER NOT NULL,
    content TEXT NOT NULL,
    parentsFed INTEGER,  -- NULL = fed everything
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modifiedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
) STRICT;

DROP TABLE IF EXISTS messageModel;
CREATE TABLE IF NOT EXISTS messageModelV2 (
    messageId INTEGER NOT NULL REFERENCES message(id) ON DELETE CASCADE,
    model TEXT NOT NULL
) STRICT;

DROP TABLE IF EXISTS audioCache;  -- migrate

CREATE TABLE IF NOT EXISTS messageTTSCache (
    messageId INTEGER NOT NULL REFERENCES message(id) ON DELETE CASCADE,
    ssml TEXT NOT NULL,
    audio BLOB NOT NULL,
    PRIMARY KEY (messageId, ssml)
) STRICT;

CREATE TABLE IF NOT EXISTS systemTTSCache (
    ssml TEXT NOT NULL PRIMARY KEY,
    audio BLOB NOT NULL
) STRICT;

CREATE TABLE IF NOT EXISTS threadName (
    messageId INTEGER NOT NULL PRIMARY KEY REFERENCES message(id) ON DELETE CASCADE,
    name TEXT NOT NULL
) STRICT;

CREATE TRIGGER IF NOT EXISTS trigger_message_update UPDATE OF role, status, content ON message
BEGIN
    UPDATE message SET modifiedAt = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

CREATE TABLE IF NOT EXISTS textCompletionUsage (
    model TEXT NOT NULL,
    prompt_tokens INTEGER NOT NULL,
    completion_tokens INTEGER NOT NULL,
    total_tokens INTEGER NOT NULL,
    timestamp TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
) STRICT;

CREATE TABLE IF NOT EXISTS textToSpeechUsage (
    region TEXT NOT NULL,
    numCharacters INTEGER NOT NULL,
    timestamp TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
) STRICT;

CREATE TABLE IF NOT EXISTS speechToTextUsage (
    model TEXT NOT NULL,
    durationMs INTEGER NOT NULL,
    timestamp TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
) STRICT;

CREATE TABLE IF NOT EXISTS bookmark (
    messageId INTEGER NOT NULL PRIMARY KEY REFERENCES message(id) ON DELETE CASCADE,
    note TEXT NOT NULL
) STRICT;

INSERT OR IGNORE INTO config VALUES ('budget', 1.0);
INSERT OR IGNORE INTO config VALUES ('maxCostPerMessage', 0.015);
