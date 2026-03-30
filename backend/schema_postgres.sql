CREATE TABLE IF NOT EXISTS words (
  id SERIAL PRIMARY KEY,
  word TEXT NOT NULL UNIQUE,
  pronunciation TEXT,
  part_of_speech TEXT,
  frequency TEXT,
  register TEXT,
  etymology TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS word_senses (
  id SERIAL PRIMARY KEY,
  word_id INTEGER NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  sense_order INTEGER NOT NULL,
  definition TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS word_examples (
  id SERIAL PRIMARY KEY,
  word_id INTEGER NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  example_text TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS topics (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT
);

CREATE TABLE IF NOT EXISTS word_topics (
  word_id INTEGER NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  topic_id INTEGER NOT NULL REFERENCES topics(id) ON DELETE CASCADE,
  PRIMARY KEY(word_id, topic_id)
);

CREATE TABLE IF NOT EXISTS synonyms (
  id SERIAL PRIMARY KEY,
  word_id INTEGER NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  synonym_word_id INTEGER NOT NULL REFERENCES words(id) ON DELETE NO ACTION,
  intensity INTEGER,
  frequency TEXT,
  note TEXT
);

CREATE TABLE IF NOT EXISTS proverbs (
  id SERIAL PRIMARY KEY,
  word_id INTEGER NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  phrase TEXT NOT NULL,
  meaning TEXT,
  usage TEXT
);

CREATE TABLE IF NOT EXISTS related_words (
  id SERIAL PRIMARY KEY,
  word_id INTEGER NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  related_word_id INTEGER NOT NULL REFERENCES words(id) ON DELETE NO ACTION
);

CREATE INDEX IF NOT EXISTS idx_words_word ON words(word);
