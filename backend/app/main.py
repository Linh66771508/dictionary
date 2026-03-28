from typing import List, Optional

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from .db import execute, execute_insert, get_conn, init_db, query_all, query_one

app = FastAPI(title="Vietnamese Dictionary API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def on_startup():
    init_db()


class TopicOut(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    icon: Optional[str] = None
    word_count: int


class WordSummary(BaseModel):
    id: int
    word: str
    part_of_speech: Optional[str] = None
    short_def: Optional[str] = None


class SynonymOut(BaseModel):
    id: int
    word: str
    intensity: Optional[int] = None
    frequency: Optional[str] = None
    note: Optional[str] = None


class ProverbOut(BaseModel):
    id: int
    phrase: str
    meaning: Optional[str] = None
    usage: Optional[str] = None


class WordDetail(BaseModel):
    id: int
    word: str
    pronunciation: Optional[str] = None
    part_of_speech: Optional[str] = None
    frequency: Optional[str] = None
    register: Optional[str] = None
    etymology: Optional[str] = None
    meanings: List[str] = Field(default_factory=list)
    examples: List[str] = Field(default_factory=list)
    synonyms: List[SynonymOut] = Field(default_factory=list)
    proverbs: List[ProverbOut] = Field(default_factory=list)
    topics: List[TopicOut] = Field(default_factory=list)
    related_words: List[str] = Field(default_factory=list)


class SynonymCreate(BaseModel):
    word: str
    intensity: Optional[int] = None
    frequency: Optional[str] = None
    note: Optional[str] = None


class ProverbCreate(BaseModel):
    phrase: str
    meaning: Optional[str] = None
    usage: Optional[str] = None


class WordCreate(BaseModel):
    word: str
    pronunciation: Optional[str] = None
    part_of_speech: Optional[str] = None
    frequency: Optional[str] = None
    register: Optional[str] = None
    etymology: Optional[str] = None
    meanings: List[str] = Field(default_factory=list)
    examples: List[str] = Field(default_factory=list)
    topic_ids: List[int] = Field(default_factory=list)
    synonyms: List[SynonymCreate] = Field(default_factory=list)
    proverbs: List[ProverbCreate] = Field(default_factory=list)
    related_words: List[str] = Field(default_factory=list)


class AdminStats(BaseModel):
    total_words: int
    total_synonyms: int
    total_proverbs: int


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/topics", response_model=List[TopicOut])
def list_topics():
    rows = query_all(
        """
        SELECT t.id, t.name, t.description, t.icon,
               (SELECT COUNT(*) FROM word_topics wt WHERE wt.topic_id = t.id) AS word_count
        FROM topics t
        ORDER BY t.name
        """
    )
    return rows


@app.get("/topics/{topic_id}/words", response_model=List[WordSummary])
def list_topic_words(topic_id: int):
    rows = query_all(
        """
        SELECT w.id, w.word, w.part_of_speech,
               s.definition AS short_def
        FROM word_topics wt
        JOIN words w ON wt.word_id = w.id
        LEFT JOIN word_senses s
          ON s.word_id = w.id
         AND s.sense_order = (
            SELECT MIN(s2.sense_order)
            FROM word_senses s2
            WHERE s2.word_id = w.id
         )
        WHERE wt.topic_id = ?
        ORDER BY w.word
        """,
        [topic_id],
    )
    return rows


@app.get("/words/search", response_model=List[WordSummary])
def search_words(q: str = Query(min_length=1), limit: int = 20):
    like = f"%{q}%"
    rows = query_all(
        """
        SELECT w.id, w.word, w.part_of_speech,
               s.definition AS short_def
        FROM words w
        LEFT JOIN word_senses s
          ON s.word_id = w.id
         AND s.sense_order = (
            SELECT MIN(s2.sense_order)
            FROM word_senses s2
            WHERE s2.word_id = w.id
         )
        WHERE w.word LIKE ?
        ORDER BY w.word
        LIMIT ?
        """,
        [like, limit],
    )
    return rows


def _get_word_detail_by_id(word_id: int) -> WordDetail:
    word = query_one(
        """
        SELECT id, word, pronunciation, part_of_speech, frequency, register, etymology
        FROM words
        WHERE id = ?
        """,
        [word_id],
    )
    if not word:
        raise HTTPException(status_code=404, detail="Word not found")

    meanings = query_all(
        """
        SELECT definition
        FROM word_senses
        WHERE word_id = ?
        ORDER BY sense_order
        """,
        [word_id],
    )
    examples = query_all(
        """
        SELECT example_text
        FROM word_examples
        WHERE word_id = ?
        ORDER BY id
        """,
        [word_id],
    )
    synonyms = query_all(
        """
        SELECT s.id, w2.word, s.intensity, s.frequency, s.note
        FROM synonyms s
        JOIN words w2 ON s.synonym_word_id = w2.id
        WHERE s.word_id = ?
        ORDER BY s.intensity DESC, w2.word
        """,
        [word_id],
    )
    proverbs = query_all(
        """
        SELECT id, phrase, meaning, usage
        FROM proverbs
        WHERE word_id = ?
        ORDER BY id
        """,
        [word_id],
    )
    topics = query_all(
        """
        SELECT t.id, t.name, t.description, t.icon,
               (SELECT COUNT(*) FROM word_topics wt WHERE wt.topic_id = t.id) AS word_count
        FROM word_topics wt
        JOIN topics t ON t.id = wt.topic_id
        WHERE wt.word_id = ?
        ORDER BY t.name
        """,
        [word_id],
    )
    related = query_all(
        """
        SELECT w2.word
        FROM related_words r
        JOIN words w2 ON r.related_word_id = w2.id
        WHERE r.word_id = ?
        ORDER BY w2.word
        """,
        [word_id],
    )

    return WordDetail(
        id=word["id"],
        word=word["word"],
        pronunciation=word.get("pronunciation"),
        part_of_speech=word.get("part_of_speech"),
        frequency=word.get("frequency"),
        register=word.get("register"),
        etymology=word.get("etymology"),
        meanings=[m["definition"] for m in meanings],
        examples=[e["example_text"] for e in examples],
        synonyms=[SynonymOut(**s) for s in synonyms],
        proverbs=[ProverbOut(**p) for p in proverbs],
        topics=[TopicOut(**t) for t in topics],
        related_words=[r["word"] for r in related],
    )


@app.get("/words/id/{word_id}", response_model=WordDetail)
def get_word_by_id(word_id: int):
    return _get_word_detail_by_id(word_id)


@app.get("/words/by-text/{word_text}", response_model=WordDetail)
def get_word_by_text(word_text: str):
    row = query_one("SELECT id FROM words WHERE word = ?", [word_text])
    if not row:
        raise HTTPException(status_code=404, detail="Word not found")
    return _get_word_detail_by_id(int(row["id"]))


@app.get("/admin/stats", response_model=AdminStats)
def admin_stats():
    words = query_one("SELECT COUNT(*) AS c FROM words")
    syns = query_one("SELECT COUNT(*) AS c FROM synonyms")
    prov = query_one("SELECT COUNT(*) AS c FROM proverbs")
    return AdminStats(
        total_words=int(words["c"] if words else 0),
        total_synonyms=int(syns["c"] if syns else 0),
        total_proverbs=int(prov["c"] if prov else 0),
    )


@app.get("/admin/words", response_model=List[WordSummary])
def admin_list_words(q: Optional[str] = None, limit: int = 50, offset: int = 0):
    if q:
        like = f"%{q}%"
        rows = query_all(
            """
            SELECT w.id, w.word, w.part_of_speech,
                   s.definition AS short_def
            FROM words w
            LEFT JOIN word_senses s
              ON s.word_id = w.id
             AND s.sense_order = (
                SELECT MIN(s2.sense_order)
                FROM word_senses s2
                WHERE s2.word_id = w.id
             )
            WHERE w.word LIKE ?
            ORDER BY w.word
            LIMIT ? OFFSET ?
            """,
            [like, limit, offset],
        )
    else:
        rows = query_all(
            """
            SELECT w.id, w.word, w.part_of_speech,
                   s.definition AS short_def
            FROM words w
            LEFT JOIN word_senses s
              ON s.word_id = w.id
             AND s.sense_order = (
                SELECT MIN(s2.sense_order)
                FROM word_senses s2
                WHERE s2.word_id = w.id
             )
            ORDER BY w.word
            LIMIT ? OFFSET ?
            """,
            [limit, offset],
        )
    return rows


def _get_or_create_word_id(conn, word_text: str) -> int:
    cur = conn.cursor()
    cur.execute("SELECT id FROM words WHERE word = ?", [word_text])
    row = cur.fetchone()
    if row:
        return int(row[0])
    cur.execute(
        """
        INSERT INTO words (word)
        VALUES (?)
        """,
        [word_text],
    )
    return int(cur.lastrowid)


@app.post("/admin/words", response_model=WordDetail)
def admin_create_word(payload: WordCreate):
    with get_conn() as conn:
        cur = conn.cursor()

        cur.execute("SELECT id FROM words WHERE word = ?", [payload.word])
        existing = cur.fetchone()
        if existing:
            raise HTTPException(status_code=409, detail="Word already exists")

        cur.execute(
            """
            INSERT INTO words (word, pronunciation, part_of_speech, frequency, register, etymology)
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            [
                payload.word,
                payload.pronunciation,
                payload.part_of_speech,
                payload.frequency,
                payload.register,
                payload.etymology,
            ],
        )
        word_id = int(cur.lastrowid)

        for idx, definition in enumerate(payload.meanings, start=1):
            cur.execute(
                """
                INSERT INTO word_senses (word_id, sense_order, definition)
                VALUES (?, ?, ?)
                """,
                [word_id, idx, definition],
            )

        for example_text in payload.examples:
            cur.execute(
                """
                INSERT INTO word_examples (word_id, example_text)
                VALUES (?, ?)
                """,
                [word_id, example_text],
            )

        for topic_id in payload.topic_ids:
            cur.execute(
                """
                INSERT INTO word_topics (word_id, topic_id)
                VALUES (?, ?)
                """,
                [word_id, topic_id],
            )

        for syn in payload.synonyms:
            syn_id = _get_or_create_word_id(conn, syn.word)
            cur.execute(
                """
                INSERT INTO synonyms (word_id, synonym_word_id, intensity, frequency, note)
                VALUES (?, ?, ?, ?, ?)
                """,
                [word_id, syn_id, syn.intensity, syn.frequency, syn.note],
            )

        for prov in payload.proverbs:
            cur.execute(
                """
                INSERT INTO proverbs (word_id, phrase, meaning, usage)
                VALUES (?, ?, ?, ?)
                """,
                [word_id, prov.phrase, prov.meaning, prov.usage],
            )

        for related_word in payload.related_words:
            related_id = _get_or_create_word_id(conn, related_word)
            cur.execute(
                """
                INSERT INTO related_words (word_id, related_word_id)
                VALUES (?, ?)
                """,
                [word_id, related_id],
            )

        conn.commit()

    return _get_word_detail_by_id(word_id)


@app.delete("/admin/words/{word_id}")
def admin_delete_word(word_id: int):
    deleted = execute("DELETE FROM words WHERE id = ?", [word_id])
    if deleted == 0:
        raise HTTPException(status_code=404, detail="Word not found")
    return {"status": "deleted"}


@app.get("/admin/synonyms", response_model=List[SynonymOut])
def admin_list_synonyms(limit: int = 100, offset: int = 0):
    rows = query_all(
        """
        SELECT s.id, w2.word, s.intensity, s.frequency, s.note
        FROM synonyms s
        JOIN words w2 ON s.synonym_word_id = w2.id
        ORDER BY s.id DESC
        LIMIT ? OFFSET ?
        """,
        [limit, offset],
    )
    return rows


@app.post("/admin/synonyms")
def admin_create_synonym(word_id: int, synonym_word: str, intensity: Optional[int] = None, frequency: Optional[str] = None, note: Optional[str] = None):
    with get_conn() as conn:
        syn_id = _get_or_create_word_id(conn, synonym_word)
        cur = conn.cursor()
        cur.execute(
            """
            INSERT INTO synonyms (word_id, synonym_word_id, intensity, frequency, note)
            VALUES (?, ?, ?, ?, ?)
            """,
            [word_id, syn_id, intensity, frequency, note],
        )
        conn.commit()
    return {"status": "created"}


@app.delete("/admin/synonyms/{synonym_id}")
def admin_delete_synonym(synonym_id: int):
    deleted = execute("DELETE FROM synonyms WHERE id = ?", [synonym_id])
    if deleted == 0:
        raise HTTPException(status_code=404, detail="Synonym not found")
    return {"status": "deleted"}


@app.get("/admin/proverbs", response_model=List[ProverbOut])
def admin_list_proverbs(limit: int = 100, offset: int = 0):
    rows = query_all(
        """
        SELECT id, phrase, meaning, usage
        FROM proverbs
        ORDER BY id DESC
        LIMIT ? OFFSET ?
        """,
        [limit, offset],
    )
    return rows


@app.post("/admin/proverbs")
def admin_create_proverb(word_id: int, phrase: str, meaning: Optional[str] = None, usage: Optional[str] = None):
    execute(
        """
        INSERT INTO proverbs (word_id, phrase, meaning, usage)
        VALUES (?, ?, ?, ?)
        """,
        [word_id, phrase, meaning, usage],
    )
    return {"status": "created"}


@app.delete("/admin/proverbs/{proverb_id}")
def admin_delete_proverb(proverb_id: int):
    deleted = execute("DELETE FROM proverbs WHERE id = ?", [proverb_id])
    if deleted == 0:
        raise HTTPException(status_code=404, detail="Proverb not found")
    return {"status": "deleted"}
