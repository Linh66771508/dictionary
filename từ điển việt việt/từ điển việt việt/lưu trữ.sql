-- Tạo database (nếu chưa có)
IF DB_ID(N'VietnameseDictionary') IS NULL
BEGIN
    CREATE DATABASE VietnameseDictionary;
END
GO

USE VietnameseDictionary;
GO

-- Bảng từ vựng
IF OBJECT_ID('dbo.words', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.words (
        id INT IDENTITY(1,1) PRIMARY KEY,
        word NVARCHAR(255) NOT NULL UNIQUE,
        pronunciation NVARCHAR(255) NULL,
        part_of_speech NVARCHAR(100) NULL,
        frequency NVARCHAR(50) NULL,
        register NVARCHAR(50) NULL,
        etymology NVARCHAR(MAX) NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END
GO

-- Nghĩa của từ
IF OBJECT_ID('dbo.word_senses', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.word_senses (
        id INT IDENTITY(1,1) PRIMARY KEY,
        word_id INT NOT NULL,
        sense_order INT NOT NULL,
        definition NVARCHAR(MAX) NOT NULL,
        CONSTRAINT FK_word_senses_words FOREIGN KEY (word_id) REFERENCES dbo.words(id) ON DELETE CASCADE
    );
END
GO

-- Ví dụ
IF OBJECT_ID('dbo.word_examples', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.word_examples (
        id INT IDENTITY(1,1) PRIMARY KEY,
        word_id INT NOT NULL,
        example_text NVARCHAR(MAX) NOT NULL,
        CONSTRAINT FK_word_examples_words FOREIGN KEY (word_id) REFERENCES dbo.words(id) ON DELETE CASCADE
    );
END
GO

-- Chủ đề
IF OBJECT_ID('dbo.topics', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.topics (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(255) NOT NULL,
        description NVARCHAR(500) NULL,
        icon NVARCHAR(50) NULL
    );
END
GO

-- Liên kết từ - chủ đề
IF OBJECT_ID('dbo.word_topics', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.word_topics (
        word_id INT NOT NULL,
        topic_id INT NOT NULL,
        CONSTRAINT PK_word_topics PRIMARY KEY (word_id, topic_id),
        CONSTRAINT FK_word_topics_words FOREIGN KEY (word_id) REFERENCES dbo.words(id) ON DELETE CASCADE,
        CONSTRAINT FK_word_topics_topics FOREIGN KEY (topic_id) REFERENCES dbo.topics(id) ON DELETE CASCADE
    );
END
GO

-- Đồng nghĩa
IF OBJECT_ID('dbo.synonyms', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.synonyms (
        id INT IDENTITY(1,1) PRIMARY KEY,
        word_id INT NOT NULL,
        synonym_word_id INT NOT NULL,
        intensity INT NULL,
        frequency NVARCHAR(50) NULL,
        note NVARCHAR(255) NULL,
        CONSTRAINT FK_synonyms_words FOREIGN KEY (word_id) REFERENCES dbo.words(id) ON DELETE CASCADE,
        CONSTRAINT FK_synonyms_words_ref FOREIGN KEY (synonym_word_id) REFERENCES dbo.words(id) ON DELETE NO ACTION
    );
END
GO

-- Tục ngữ / thành ngữ
IF OBJECT_ID('dbo.proverbs', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.proverbs (
        id INT IDENTITY(1,1) PRIMARY KEY,
        word_id INT NOT NULL,
        phrase NVARCHAR(500) NOT NULL,
        meaning NVARCHAR(MAX) NULL,
        usage NVARCHAR(255) NULL,
        CONSTRAINT FK_proverbs_words FOREIGN KEY (word_id) REFERENCES dbo.words(id) ON DELETE CASCADE
    );
END
GO

-- Từ liên quan
IF OBJECT_ID('dbo.related_words', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.related_words (
        id INT IDENTITY(1,1) PRIMARY KEY,
        word_id INT NOT NULL,
        related_word_id INT NOT NULL,
        CONSTRAINT FK_related_words_words FOREIGN KEY (word_id) REFERENCES dbo.words(id) ON DELETE CASCADE,
        CONSTRAINT FK_related_words_words_ref FOREIGN KEY (related_word_id) REFERENCES dbo.words(id) ON DELETE NO ACTION
    );
END
GO

-- Index hỗ trợ tìm kiếm
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_words_word' AND object_id = OBJECT_ID('dbo.words'))
BEGIN
    CREATE INDEX IX_words_word ON dbo.words(word);
END
GO
