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


class TopicCreate(BaseModel):
    name: str
    description: Optional[str] = None
    icon: Optional[str] = None


class WordSummary(BaseModel):
    id: int
    word: str
    part_of_speech: Optional[str] = None
    short_def: Optional[str] = None


class MeaningOut(BaseModel):
    id: int
    definition: str
    sense_order: int


class ExampleOut(BaseModel):
    id: int
    example_text: str


class SynonymOut(BaseModel):
    id: int
    word: Optional[str] = None
    synonym_word: Optional[str] = None
    word_id: Optional[int] = None
    synonym_word_id: Optional[int] = None
    intensity: Optional[int] = None
    frequency: Optional[str] = None
    note: Optional[str] = None


class ProverbOut(BaseModel):
    id: int
    word_id: Optional[int] = None
    word: Optional[str] = None
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
    meanings: List[MeaningOut] = Field(default_factory=list)
    examples: List[ExampleOut] = Field(default_factory=list)
    synonyms: List[SynonymOut] = Field(default_factory=list)
    proverbs: List[ProverbOut] = Field(default_factory=list)
    topics: List[TopicOut] = Field(default_factory=list)
    related_words: List[str] = Field(default_factory=list)


class SynonymCreate(BaseModel):
    word: str
    intensity: Optional[int] = None
    frequency: Optional[str] = None
    note: Optional[str] = None


class SynonymUpdate(BaseModel):
    synonym_word: Optional[str] = None
    intensity: Optional[int] = None
    frequency: Optional[str] = None
    note: Optional[str] = None


class ProverbCreate(BaseModel):
    phrase: str
    meaning: Optional[str] = None
    usage: Optional[str] = None


class ProverbUpdate(BaseModel):
    phrase: Optional[str] = None
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


class WordUpdate(BaseModel):
    word: Optional[str] = None
    pronunciation: Optional[str] = None
    part_of_speech: Optional[str] = None
    frequency: Optional[str] = None
    register: Optional[str] = None
    etymology: Optional[str] = None


class MeaningCreate(BaseModel):
    definition: str
    sense_order: Optional[int] = None


class MeaningUpdate(BaseModel):
    definition: Optional[str] = None
    sense_order: Optional[int] = None


class ExampleCreate(BaseModel):
    example_text: str


class ExampleUpdate(BaseModel):
    example_text: Optional[str] = None


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
        SELECT id, definition, sense_order
        FROM word_senses
        WHERE word_id = ?
        ORDER BY sense_order
        """,
        [word_id],
    )
    examples = query_all(
        """
        SELECT id, example_text
        FROM word_examples
        WHERE word_id = ?
        ORDER BY id
        """,
        [word_id],
    )
    synonyms = query_all(
        """
        SELECT s.id, s.word_id, w.word AS word,
               s.synonym_word_id, w2.word AS synonym_word,
               s.intensity, s.frequency, s.note
        FROM synonyms s
        JOIN words w ON s.word_id = w.id
        JOIN words w2 ON s.synonym_word_id = w2.id
        WHERE s.word_id = ?
        ORDER BY s.intensity DESC, w2.word
        """,
        [word_id],
    )
    proverbs = query_all(
        """
        SELECT p.id, p.word_id, w.word AS word, p.phrase, p.meaning, p.usage
        FROM proverbs p
        JOIN words w ON p.word_id = w.id
        WHERE p.word_id = ?
        ORDER BY p.id
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
        meanings=[MeaningOut(**m) for m in meanings],
        examples=[ExampleOut(**e) for e in examples],
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


@app.put("/admin/words/{word_id}", response_model=WordDetail)
def admin_update_word(word_id: int, payload: WordUpdate):
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("SELECT id FROM words WHERE id = ?", [word_id])
        if not cur.fetchone():
            raise HTTPException(status_code=404, detail="Word not found")

        updates = []
        params = []
        if payload.word is not None:
            cur.execute("SELECT id FROM words WHERE word = ? AND id != ?", [payload.word, word_id])
            if cur.fetchone():
                raise HTTPException(status_code=409, detail="Word already exists")
            updates.append("word = ?")
            params.append(payload.word)
        if payload.pronunciation is not None:
            updates.append("pronunciation = ?")
            params.append(payload.pronunciation)
        if payload.part_of_speech is not None:
            updates.append("part_of_speech = ?")
            params.append(payload.part_of_speech)
        if payload.frequency is not None:
            updates.append("frequency = ?")
            params.append(payload.frequency)
        if payload.register is not None:
            updates.append("register = ?")
            params.append(payload.register)
        if payload.etymology is not None:
            updates.append("etymology = ?")
            params.append(payload.etymology)

        if updates:
            sql = "UPDATE words SET " + ", ".join(updates) + " WHERE id = ?"
            params.append(word_id)
            cur.execute(sql, params)
            conn.commit()

    return _get_word_detail_by_id(word_id)


@app.delete("/admin/words/{word_id}")
def admin_delete_word(word_id: int):
    deleted = execute("DELETE FROM words WHERE id = ?", [word_id])
    if deleted == 0:
        raise HTTPException(status_code=404, detail="Word not found")
    return {"status": "deleted"}


@app.post("/admin/words/{word_id}/meanings", response_model=MeaningOut)
def admin_add_meaning(word_id: int, payload: MeaningCreate):
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("SELECT id FROM words WHERE id = ?", [word_id])
        if not cur.fetchone():
            raise HTTPException(status_code=404, detail="Word not found")

        if payload.sense_order is None:
            cur.execute("SELECT COALESCE(MAX(sense_order), 0) + 1 FROM word_senses WHERE word_id = ?", [word_id])
            payload.sense_order = int(cur.fetchone()[0])

        cur.execute(
            """
            INSERT INTO word_senses (word_id, sense_order, definition)
            VALUES (?, ?, ?)
            """,
            [word_id, payload.sense_order, payload.definition],
        )
        conn.commit()
        meaning_id = int(cur.lastrowid)

    return MeaningOut(id=meaning_id, definition=payload.definition, sense_order=payload.sense_order)


@app.put("/admin/meanings/{meaning_id}")
def admin_update_meaning(meaning_id: int, payload: MeaningUpdate):
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("SELECT id FROM word_senses WHERE id = ?", [meaning_id])
        if not cur.fetchone():
            raise HTTPException(status_code=404, detail="Meaning not found")

        updates = []
        params = []
        if payload.definition is not None:
            updates.append("definition = ?")
            params.append(payload.definition)
        if payload.sense_order is not None:
            updates.append("sense_order = ?")
            params.append(payload.sense_order)
        if updates:
            sql = "UPDATE word_senses SET " + ", ".join(updates) + " WHERE id = ?"
            params.append(meaning_id)
            cur.execute(sql, params)
            conn.commit()

    return {"status": "updated"}


@app.delete("/admin/meanings/{meaning_id}")
def admin_delete_meaning(meaning_id: int):
    deleted = execute("DELETE FROM word_senses WHERE id = ?", [meaning_id])
    if deleted == 0:
        raise HTTPException(status_code=404, detail="Meaning not found")
    return {"status": "deleted"}


@app.post("/admin/words/{word_id}/examples", response_model=ExampleOut)
def admin_add_example(word_id: int, payload: ExampleCreate):
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("SELECT id FROM words WHERE id = ?", [word_id])
        if not cur.fetchone():
            raise HTTPException(status_code=404, detail="Word not found")

        cur.execute(
            """
            INSERT INTO word_examples (word_id, example_text)
            VALUES (?, ?)
            """,
            [word_id, payload.example_text],
        )
        conn.commit()
        example_id = int(cur.lastrowid)

    return ExampleOut(id=example_id, example_text=payload.example_text)


@app.put("/admin/examples/{example_id}")
def admin_update_example(example_id: int, payload: ExampleUpdate):
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("SELECT id FROM word_examples WHERE id = ?", [example_id])
        if not cur.fetchone():
            raise HTTPException(status_code=404, detail="Example not found")

        updates = []
        params = []
        if payload.example_text is not None:
            updates.append("example_text = ?")
            params.append(payload.example_text)
        if updates:
            sql = "UPDATE word_examples SET " + ", ".join(updates) + " WHERE id = ?"
            params.append(example_id)
            cur.execute(sql, params)
            conn.commit()

    return {"status": "updated"}


@app.delete("/admin/examples/{example_id}")
def admin_delete_example(example_id: int):
    deleted = execute("DELETE FROM word_examples WHERE id = ?", [example_id])
    if deleted == 0:
        raise HTTPException(status_code=404, detail="Example not found")
    return {"status": "deleted"}


@app.get("/admin/synonyms", response_model=List[SynonymOut])
def admin_list_synonyms(limit: int = 200, offset: int = 0):
    rows = query_all(
        """
        SELECT s.id, s.word_id, w.word AS word,
               s.synonym_word_id, w2.word AS synonym_word,
               s.intensity, s.frequency, s.note
        FROM synonyms s
        JOIN words w ON s.word_id = w.id
        JOIN words w2 ON s.synonym_word_id = w2.id
        ORDER BY s.id DESC
        LIMIT ? OFFSET ?
        """,
        [limit, offset],
    )
    return rows


@app.post("/admin/synonyms")
def admin_create_synonym(word_id: int, payload: SynonymCreate):
    with get_conn() as conn:
        syn_id = _get_or_create_word_id(conn, payload.word)
        cur = conn.cursor()
        cur.execute(
            """
            INSERT INTO synonyms (word_id, synonym_word_id, intensity, frequency, note)
            VALUES (?, ?, ?, ?, ?)
            """,
            [word_id, syn_id, payload.intensity, payload.frequency, payload.note],
        )
        conn.commit()
    return {"status": "created"}


@app.put("/admin/synonyms/{synonym_id}")
def admin_update_synonym(synonym_id: int, payload: SynonymUpdate):
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("SELECT word_id FROM synonyms WHERE id = ?", [synonym_id])
        row = cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Synonym not found")

        updates = []
        params = []
        if payload.synonym_word is not None:
            syn_id = _get_or_create_word_id(conn, payload.synonym_word)
            updates.append("synonym_word_id = ?")
            params.append(syn_id)
        if payload.intensity is not None:
            updates.append("intensity = ?")
            params.append(payload.intensity)
        if payload.frequency is not None:
            updates.append("frequency = ?")
            params.append(payload.frequency)
        if payload.note is not None:
            updates.append("note = ?")
            params.append(payload.note)

        if updates:
            sql = "UPDATE synonyms SET " + ", ".join(updates) + " WHERE id = ?"
            params.append(synonym_id)
            cur.execute(sql, params)
            conn.commit()

    return {"status": "updated"}


@app.delete("/admin/synonyms/{synonym_id}")
def admin_delete_synonym(synonym_id: int):
    deleted = execute("DELETE FROM synonyms WHERE id = ?", [synonym_id])
    if deleted == 0:
        raise HTTPException(status_code=404, detail="Synonym not found")
    return {"status": "deleted"}


@app.get("/admin/proverbs", response_model=List[ProverbOut])
def admin_list_proverbs(limit: int = 200, offset: int = 0):
    rows = query_all(
        """
        SELECT p.id, p.word_id, w.word AS word, p.phrase, p.meaning, p.usage
        FROM proverbs p
        JOIN words w ON p.word_id = w.id
        ORDER BY p.id DESC
        LIMIT ? OFFSET ?
        """,
        [limit, offset],
    )
    return rows


@app.post("/admin/proverbs")
def admin_create_proverb(word_id: int, payload: ProverbCreate):
    execute(
        """
        INSERT INTO proverbs (word_id, phrase, meaning, usage)
        VALUES (?, ?, ?, ?)
        """,
        [word_id, payload.phrase, payload.meaning, payload.usage],
    )
    return {"status": "created"}


@app.put("/admin/proverbs/{proverb_id}")
def admin_update_proverb(proverb_id: int, payload: ProverbUpdate):
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("SELECT id FROM proverbs WHERE id = ?", [proverb_id])
        if not cur.fetchone():
            raise HTTPException(status_code=404, detail="Proverb not found")

        updates = []
        params = []
        if payload.phrase is not None:
            updates.append("phrase = ?")
            params.append(payload.phrase)
        if payload.meaning is not None:
            updates.append("meaning = ?")
            params.append(payload.meaning)
        if payload.usage is not None:
            updates.append("usage = ?")
            params.append(payload.usage)
        if updates:
            sql = "UPDATE proverbs SET " + ", ".join(updates) + " WHERE id = ?"
            params.append(proverb_id)
            cur.execute(sql, params)
            conn.commit()

    return {"status": "updated"}


@app.delete("/admin/proverbs/{proverb_id}")
def admin_delete_proverb(proverb_id: int):
    deleted = execute("DELETE FROM proverbs WHERE id = ?", [proverb_id])
    if deleted == 0:
        raise HTTPException(status_code=404, detail="Proverb not found")
    return {"status": "deleted"}


@app.post("/admin/topics")
def admin_create_topic(payload: TopicCreate):
    if not payload.name.strip():
        raise HTTPException(status_code=400, detail="Topic name is required")
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute(
            """
            INSERT INTO topics (name, description, icon)
            VALUES (?, ?, ?)
            """,
            [payload.name.strip(), payload.description, payload.icon],
        )
        conn.commit()
        topic_id = int(cur.lastrowid)
    return {"status": "created", "id": topic_id}


@app.delete("/admin/topics/{topic_id}")
def admin_delete_topic(topic_id: int):
    deleted = execute("DELETE FROM topics WHERE id = ?", [topic_id])
    if deleted == 0:
        raise HTTPException(status_code=404, detail="Topic not found")
    return {"status": "deleted"}


@app.post("/admin/topics/{topic_id}/words/{word_id}")
def admin_add_word_to_topic(topic_id: int, word_id: int):
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute("SELECT id FROM topics WHERE id = ?", [topic_id])
        if not cur.fetchone():
            raise HTTPException(status_code=404, detail="Topic not found")
        cur.execute("SELECT id FROM words WHERE id = ?", [word_id])
        if not cur.fetchone():
            raise HTTPException(status_code=404, detail="Word not found")
        cur.execute(
            """
            INSERT OR IGNORE INTO word_topics (word_id, topic_id)
            VALUES (?, ?)
            """,
            [word_id, topic_id],
        )
        conn.commit()
    return {"status": "created"}


@app.delete("/admin/topics/{topic_id}/words/{word_id}")
def admin_remove_word_from_topic(topic_id: int, word_id: int):
    deleted = execute(
        "DELETE FROM word_topics WHERE topic_id = ? AND word_id = ?",
        [topic_id, word_id],
    )
    if deleted == 0:
        raise HTTPException(status_code=404, detail="Word not in topic")
    return {"status": "deleted"}
