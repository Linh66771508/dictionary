# ============================================================================
# File: main.py - Máy chủ API chính cho ứng dụng từ điển
# Tác dụng: Cung cấp các endpoint (đường dẫn) để app gọi để lấy dữ liệu từ điển
# ============================================================================

from typing import List, Optional

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from .db import execute, execute_insert, get_conn, init_db, query_all, query_one

# Khởi tạo ứng dụng FastAPI - đây là máy chủ web
app = FastAPI(title="Vietnamese Dictionary API")

# Cấu hình CORS - cho phép các app khác gọi API từ máy chủ này
# allow_origins=["*"] = cho phép mọi nguồn gọi
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Khi máy chủ khởi động, hãy khởi tạo database
@app.on_event("startup")
def on_startup():
    """Chạy lần đầu tiên khi máy chủ bắt đầu hoạt động"""
    init_db()


# ============================================================================
# Định nghĩa các lớp Model - mô tả cấu trúc dữ liệu gửi/nhận từ API
# ============================================================================

# Model cho Chủ đề (Topic) - ví dụ: "Thực vật", "Động vật", v.v.
class TopicOut(BaseModel):
    id: int                                  # ID chủ đề
    name: str                                # Tên chủ đề
    description: Optional[str] = None        # Mô tả chủ đề (có thể trống)
    icon: Optional[str] = None               # Biểu tượng chủ đề (có thể trống)
    word_count: int                          # Số từ trong chủ đề này


# Model để tạo chủ đề mới (không cần ID vì database sẽ tự sinh)
class TopicCreate(BaseModel):
    name: str                                # Tên chủ đề
    description: Optional[str] = None        # Mô tả (không bắt buộc)
    icon: Optional[str] = None               # Biểu tượng (không bắt buộc)


# Model tóm tắt từ vựng (dùng khi hiển thị danh sách)
class WordSummary(BaseModel):
    id: int                                  # ID từ
    word: str                                # Từ tiếng Việt
    part_of_speech: Optional[str] = None     # Loại từ (danh từ, động từ, ...)
    short_def: Optional[str] = None          # Định nghĩa ngắn


# Model cho Nghĩa của từ
class MeaningOut(BaseModel):
    id: int                                  # ID nghĩa
    definition: str                          # Định nghĩa chi tiết
    sense_order: int                         # Thứ tự nghĩa (từ 1, 2, 3, ...)


# Model cho Ví dụ sử dụng từ
class ExampleOut(BaseModel):
    id: int                                  # ID ví dụ
    example_text: str                        # Câu ví dụ


# Model cho Từ đồng nghĩa
class SynonymOut(BaseModel):
    id: int                                  # ID mối quan hệ đồng nghĩa
    word: Optional[str] = None               # Từ gốc
    synonym_word: Optional[str] = None       # Từ đồng nghĩa
    word_id: Optional[int] = None            # ID từ gốc
    synonym_word_id: Optional[int] = None    # ID từ đồng nghĩa
    intensity: Optional[int] = None          # Mức độ tương tự (1-5)
    frequency: Optional[str] = None          # Tần suất sử dụng
    note: Optional[str] = None               # Ghi chú thêm


# Model cho Thành ngữ/Tục ngữ liên quan tới từ
class ProverbOut(BaseModel):
    id: int                                  # ID thành ngữ
    word_id: Optional[int] = None            # ID từ liên quan
    word: Optional[str] = None               # Từ liên quan
    phrase: str                              # Thành ngữ/tục ngữ
    meaning: Optional[str] = None            # Ý nghĩa
    usage: Optional[str] = None              # Cách sử dụng


# Model chi tiết của một từ - chứa TẤT CẢ thông tin về từ
class WordDetail(BaseModel):
    id: int                                  # ID từ
    word: str                                # Từ tiếng Việt
    pronunciation: Optional[str] = None      # Cách phát âm
    part_of_speech: Optional[str] = None     # Loại từ (noun, verb, ...)
    frequency: Optional[str] = None          # Tần suất sử dụng (thường, hiếm, ...)
    register: Optional[str] = None           # Mức độ trang trọng (lịch sử, hiện đại, ...)
    etymology: Optional[str] = None          # Nguồn gốc từ
    meanings: List[MeaningOut] = Field(default_factory=list)        # Danh sách nghĩa
    examples: List[ExampleOut] = Field(default_factory=list)        # Danh sách ví dụ
    synonyms: List[SynonymOut] = Field(default_factory=list)        # Danh sách từ đồng nghĩa
    proverbs: List[ProverbOut] = Field(default_factory=list)        # Danh sách thành ngữ liên quan
    topics: List[TopicOut] = Field(default_factory=list)            # Danh sách chủ đề
    related_words: List[str] = Field(default_factory=list)          # Danh sách từ liên quan khác


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


# ============================================================================
# ENDPOINTS - Duong dan API ma app goi de lay du lieu
# ============================================================================

# Endpoint test: Kiem tra server co hoat dong khong?
# HTTP: GET /health
# Response: {"status": "ok"}
@app.get("/health")
def health():
    """Kiem tra trang thai server - dung de test API hoat dong"""
    return {"status": "ok"}


# Lay danh sach TAT CA chu de
# HTTP: GET /topics
# Response: [
#   {"id": 1, "name": "Thuc vat", "description": "...", "icon": "...", "word_count": 45},
#   {"id": 2, "name": "Dong vat", "description": "...", "icon": "...", "word_count": 30}
# ]
@app.get("/topics", response_model=List[TopicOut])
def list_topics():
    """Lay danh sach tat ca cac chu de trong tu dien"""
    rows = query_all(
        """
        SELECT t.id, t.name, t.description, t.icon,
               (SELECT COUNT(*) FROM word_topics wt WHERE wt.topic_id = t.id) AS word_count
        FROM topics t
        ORDER BY t.name
        """
    )
    return rows


# Lay danh sach TAt CA cac tu trong mot chu de
# HTTP: GET /topics/{topic_id}/words
# Tham so: topic_id = ID chu de
# Response: [
#   {"id": 1, "word": "hoa", "part_of_speech": "danh tu", "short_def": "cay co hoa"},
#   {"id": 2, "word": "la", "part_of_speech": "danh tu", "short_def": "phan cu cay"}
# ]
@app.get("/topics/{topic_id}/words", response_model=List[WordSummary])
def list_topic_words(topic_id: int):
    """Lay danh sach tat ca cac tu trong mot chu de nhat dinh"""
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


# Tim kiem tu theo tu khoa
# HTTP: GET /words/search?q=<tu_khoa>&limit=<so_luong>
# Tham so:
#   - q: Tu khoa tim kiem (bat buoc, toi thieu 1 ky tu)
#   - limit: So luong ket qua toi da (mac dinh: 20)
# Response: [
#   {"id": 5, "word": "yeu", "part_of_speech": "dong tu", "short_def": "co cam tinh"},
#   {...}
# ]
@app.get("/words/search", response_model=List[WordSummary])
def search_words(q: str = Query(min_length=1), limit: int = 20):
    """Tim kiem cac tu theo tu khoa"""
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
    """
    Lấy thông tin chi tiết của một từ từ cơ sở dữ liệu.
    
    Tham số:
        word_id (int): ID của từ cần lấy thông tin
    
    Giá trị trả về:
        WordDetail: Object chứa đầy đủ thông tin của từ bao gồm:
                   - Thông tin cơ bản: từ, cách phát âm, loại từ, tần suất, cách dùng, nguồn gốc
                   - Tất cả các định nghĩa (meanings/senses)
                   - Tất cả các ví dụ sử dụng
                   - Tất cả các từ đồng nghĩa với mức độ tương tự
                   - Tất cả các tục ngữ/thành ngữ liên quan
                   - Danh sách topic mà từ thuộc về
                   - Các từ liên quan
    
    Process flow:
        1. Truy vấn thông tin cơ bản của từ từ bảng 'words'
        2. Nếu không tìm thấy từ -> raise HTTPException 404
        3. Truy vấn tất cả các định nghĩa từ bảng 'word_senses' (sắp xếp theo thứ tự)
        4. Truy vấn tất cả các ví dụ từ bảng 'word_examples'
        5. Truy vấn tất cả các từ đồng nghĩa từ bảng 'synonyms' + JOIN với bảng 'words'
           (sắp xếp theo intensity cao xuống thấp)
        6. Truy vấn tất cả các tục ngữ từ bảng 'proverbs' + JOIN với bảng 'words'
        7. Truy vấn các topic từ bảng 'word_topics' + JOIN với 'topics', tính word_count
        8. Truy vấn các từ liên quan từ bảng 'related_words' + JOIN với 'words'
        9. Combine tất cả dữ liệu thành object WordDetail
    
    Exception:
        HTTPException(404): Nếu từ không tồn tại trong cơ sở dữ liệu
    """
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
    """
    GET /words/id/{word_id}
    
    Lấy thông tin chi tiết của một từ theo ID.
    
    Tham số:
        word_id (int): ID của từ cần lấy (path parameter)
    
    Trả về:
        WordDetail: Đối tượng chứa toàn bộ thông tin của từ
    
    Ví dụ:
        GET /words/id/1
        Response:
        {
            "id": 1,
            "word": "thương",
            "pronunciation": "thương",
            "part_of_speech": "động từ",
            "frequency": 1,
            "register": "common",
            "etymology": "từ Hán",
            "meanings": [...],
            "examples": [...],
            "synonyms": [...],
            "proverbs": [...],
            "topics": [...],
            "related_words": [...]
        }
    
    Exception:
        404: Word not found - Từ không tồn tại
    """
    return _get_word_detail_by_id(word_id)


@app.get("/words/by-text/{word_text}", response_model=WordDetail)
def get_word_by_text(word_text: str):
    """
    GET /words/by-text/{word_text}
    
    Lấy thông tin chi tiết của một từ theo tên từ (string).
    
    Tham số:
        word_text (str): Tên của từ cần lấy (path parameter, exact match)
    
    Trả về:
        WordDetail: Đối tượng chứa toàn bộ thông tin của từ
    
    Process:
        1. Tìm kiếm ID của từ với tên chính xác trong bảng 'words'
        2. Nếu không tìm thấy -> raise HTTPException 404
        3. Gọi _get_word_detail_by_id() để lấy toàn bộ thông tin
    
    Ví dụ:
        GET /words/by-text/thương
        Response: WordDetail object (similar to /words/id/{id})
    
    Exception:
        404: Word not found - Từ không tồn tại
    """
    row = query_one("SELECT id FROM words WHERE word = ?", [word_text])
    if not row:
        raise HTTPException(status_code=404, detail="Word not found")
    return _get_word_detail_by_id(int(row["id"]))


@app.get("/admin/stats", response_model=AdminStats)
def admin_stats():
    """
    GET /admin/stats
    
    Lấy thống kê tổng hợp của từ điển (dành cho admin).
    
    Trả về:
        AdminStats: Object chứa:
                   - total_words: Tổng số từ trong từ điển
                   - total_synonyms: Tổng số mối quan hệ từ đồng nghĩa
                   - total_proverbs: Tổng số tục ngữ/thành ngữ
    
    Process:
        1. COUNT(*) từ bảng 'words' để đếm tổng số từ
        2. COUNT(*) từ bảng 'synonyms' để đếm tổng số quan hệ đồng nghĩa
        3. COUNT(*) từ bảng 'proverbs' để đếm tổng số tục ngữ
        4. Return object với các con số
    
    Ví dụ:
        GET /admin/stats
        Response:
        {
            "total_words": 5000,
            "total_synonyms": 8000,
            "total_proverbs": 200
        }
    """
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
    """
    GET /admin/words
    
    Lấy danh sách các từ (dành cho admin) với tùy chọn tìm kiếm và phân trang.
    
    Tham số:
        q (Optional[str]): Chuỗi tìm kiếm (search by word - không phân biệt hoa/thường)
                          If not provided: lấy tất cả từ
        limit (int): Số lượng kết quả mỗi trang (default: 50, max: tự định)
        offset (int): Vị trí bắt đầu (để phân trang, default: 0)
    
    Trả về:
        List[WordSummary]: Danh sách các từ tóm tắt bao gồm:
                          - id: ID của từ
                          - word: Tên từ
                          - part_of_speech: Loại từ (danh từ, động từ, tính từ, ...)
                          - short_def: Định nghĩa ngắn (lấy định nghĩa đầu tiên/chính)
    
    Process:
        1. Nếu có tham số 'q': Tìm kiếm với LIKE (chứa - case insensitive)
           - Lấy từ từ bảng 'words' WHERE word LIKE '%q%'
           - LEFT JOIN với 'word_senses' để lấy định nghĩa đầu tiên (sense_order nhỏ nhất)
           - Sắp xếp theo tên từ (alphabetical)
        2. Nếu không có 'q': Lấy tất cả từ cùng logic
        3. Áp dụng LIMIT và OFFSET để phân trang
    
    Ví dụ:
        GET /admin/words?q=th&limit=20&offset=0
        Response:
        [
            {
                "id": 1,
                "word": "thương",
                "part_of_speech": "động từ",
                "short_def": "to love, to pity"
            },
            {"id": 2, "word": "thắng", ...}
        ]
    """
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
    """
    Lấy ID của một từ, hoặc tạo từ mới nếu chưa tồn tại.
    
    Tham số:
        conn: Database connection object (SQLite connection)
        word_text (str): Tên của từ
    
    Trả về:
        int: ID của từ (từ cũ hoặc từ mới vừa tạo)
    
    Process:
        1. Truy vấn bảng 'words' để tìm từ với tên word_text
        2. Nếu tìm thấy -> return ID của nó
        3. Nếu không tìm thấy -> INSERT từ mới vào 'words' table
        4. Return lastrowid (ID của dòng vừa INSERT)
    
    Sử dụng:
        Hữu ích khi tạo từ đồng nghĩa hoặc từ liên quan mà từ đó chưa chắc tồn tại.
        Không phải là INSERT nếu từ đã tồn tại -> tránh duplicate.
    
    Ví dụ:
        word_id = _get_or_create_word_id(conn, "thương")
        # Nếu "thương" tồn tại -> return ID của nó
        # Nếu không tồn tại -> INSERT "thương" và return ID mới
    """
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
    """
    POST /admin/words
    
    Tạo một từ mới trong từ điển (dành cho admin).
    
    Tham số:
        payload (WordCreate): Object chứa thông tin từ mới:
                             - word: Tên từ (required)
                             - pronunciation: Cách phát âm
                             - part_of_speech: Loại từ
                             - frequency: Tần suất sử dụng
                             - register: Cách dùng (formal, informal, slang, ...)
                             - etymology: Nguồn gốc từ
                             - meanings: List các định nghĩa
                             - examples: List các ví dụ
                             - topic_ids: List ID của các topic
                             - synonyms: List các từ đồng nghĩa
                             - proverbs: List các tục ngữ liên quan
                             - related_words: List các từ liên quan
    
    Trả về:
        WordDetail: Object của từ vừa tạo (với tất cả thông tin đầy đủ)
    
    Process:
        1. Kiểm tra nếu từ đã tồn tại -> raise HTTPException 409 (conflict)
        2. INSERT từ mới vào bảng 'words' với tất cả thông tin cơ bản
        3. INSERT tất cả các định nghĩa vào bảng 'word_senses'
        4. INSERT tất cả các ví dụ vào bảng 'word_examples'
        5. INSERT tất cả các associations vào bảng 'word_topics'
        6. Xử lý từ đồng nghĩa:
           - Nếu từ đồng nghĩa chưa tồn tại -> tạo từ mới (using _get_or_create_word_id)
           - INSERT vào bảng 'synonyms' với intensity, frequency, note
        7. INSERT tất cả các tục ngữ vào bảng 'proverbs'
        8. Xử lý từ liên quan: tạo mới nếu cần và INSERT vào 'related_words'
        9. Commit transaction
        10. Gọi _get_word_detail_by_id() để trả về thông tin chi tiết
    
    Exception:
        409: Word already exists - Từ đã tồn tại
    
    Ví dụ Request Body:
        {
            "word": "thương",
            "pronunciation": "thương",
            "part_of_speech": "động từ",
            "frequency": 1,
            "register": "common",
            "etymology": "từ Hán",
            "meanings": ["to love", "to pity"],
            "examples": ["Tôi thương anh ấy"],
            "topic_ids": [1, 2],
            "synonyms": [{"word": "yêu", "intensity": 8, "frequency": 1, "note": ""}],
            "proverbs": [{"phrase": "...", "meaning": "...", "usage": "..."}],
            "related_words": ["yêu", "quý"]
        }
    """
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
    """
    PUT /admin/words/{word_id}
    
    Cập nhật thông tin básic của một từ (dành cho admin).
    
    Tham số:
        word_id (int): ID của từ cần cập nhật
        payload (WordUpdate): Object chứa các field cần cập nhật (optional):
                             - word: Tên từ
                             - pronunciation: Cách phát âm
                             - part_of_speech: Loại từ
                             - frequency: Tần suất
                             - register: Cách dùng
                             - etymology: Nguồn gốc
    
    Trả về:
        WordDetail: Object của từ sau khi cập nhật (với tất cả thông tin)
    
    Process:
        1. Kiểm tra từ có tồn tại không (SELECT FROM words WHERE id = ?)
           - Nếu không tồn tại -> raise HTTPException 404
        2. Nếu cập nhật trường 'word': Kiểm tra từ mới không bị duplicate
           - SELECT FROM words WHERE word = ? AND id != ?
           - Nếu tìm thấy -> raise HTTPException 409 (conflict)
        3. Build dynamic UPDATE query dựa trên các field được cung cấp
        4. Execute UPDATE statement
        5. Commit transaction
        6. Gọi _get_word_detail_by_id() để trả về thông tin cập nhật
    
    Exception:
        404: Word not found - Từ không tồn tại
        409: Word already exists - Tên từ mới đã tồn tại
    
    Note:
        - Chỉ cập nhật các field được cung cấp (partial update - PATCH style)
        - Không cập nhật meanings, examples, synonyms, proverbs, topics qua endpoint này
          (sử dụng các endpoint riêng cho từng loại)
    
    Ví dụ:
        PUT /admin/words/1
        {
            "word": "thương",
            "register": "formal"
        }
        Response: WordDetail object
    """
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
    """
    DELETE /admin/words/{word_id}
    
    Xóa một từ khỏi từ điển (dành cho admin).
    
    Tham số:
        word_id (int): ID của từ cần xóa
    
    Trả về:
        {"status": "deleted"} - Nếu xóa thành công
    
    Process:
        1. Thực thi DELETE FROM words WHERE id = ?
        2. Chú ý: SQLite sẽ tự động xóa các records liên quan từ các bảng khác
           nhờ cơ chế CASCADE (nếu được config trong schema)
           - Xóa từ 'words' -> tự động xóa từ 'word_senses', 'word_examples', 
             'synonyms' (where word_id), 'proverbs', 'word_topics', 'related_words'
        3. Nếu không tìm thấy từ (deleted = 0) -> raise HTTPException 404
        4. Return status message
    
    Exception:
        404: Word not found - Từ không tồn tại
    
    Chú ý:
        - Đây là operación destructive (không thể undo)
        - Xóa sẽ làm mất tất cả thông tin liên quan (meanings, examples, synonyms, ...)
    
    Ví dụ:
        DELETE /admin/words/1
        Response: {"status": "deleted"}
    """
    deleted = execute("DELETE FROM words WHERE id = ?", [word_id])
    if deleted == 0:
        raise HTTPException(status_code=404, detail="Word not found")
    return {"status": "deleted"}


@app.post("/admin/words/{word_id}/meanings", response_model=MeaningOut)
def admin_add_meaning(word_id: int, payload: MeaningCreate):
    """
    POST /admin/words/{word_id}/meanings
    
    Thêm một định nghĩa mới cho một từ.
    
    Tham số:
        word_id (int): ID của từ
        payload (MeaningCreate): Object chứa:
                                - definition: Nội dung định nghĩa (required)
                                - sense_order: Thứ tự của định nghĩa (optional)
                                  Nếu không cung cấp -> tự động lấy order tiếp theo
    
    Trả về:
        MeaningOut: Object của định nghĩa vừa tạo bao gồm:
                   - id: ID của định nghĩa
                   - definition: Nội dung định nghĩa
                   - sense_order: Thứ tự sắp xếp
    
    Process:
        1. Kiểm tra từ tồn tại (SELECT FROM words WHERE id = ?)
           - Nếu không tồn tại -> raise HTTPException 404
        2. Nếu sense_order không được cung cấp:
           - Query MAX(sense_order) từ từ này từ bảng 'word_senses'
           - Lấy giá trị tiếp theo (MAX + 1)
        3. INSERT vào bảng 'word_senses' với (word_id, sense_order, definition)
        4. Commit transaction
        5. Return MeaningOut object
    
    Exception:
        404: Word not found - Từ không tồn tại
    
    Ví dụ:
        POST /admin/words/1/meanings
        {
            "definition": "to love, to have affection for"
        }
        Response:
        {
            "id": 5,
            "definition": "to love, to have affection for",
            "sense_order": 2
        }
    """
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
    """
    PUT /admin/meanings/{meaning_id}
    
    Cập nhật một định nghĩa của từ.
    
    Tham số:
        meaning_id (int): ID của định nghĩa trong bảng 'word_senses'
        payload (MeaningUpdate): Object chứa các field cần cập nhật (optional):
                                - definition: Nội dung định nghĩa
                                - sense_order: Thứ tự sắp xếp
    
    Trả về:
        {"status": "updated"} - Nếu cập nhật thành công
    
    Process:
        1. Kiểm tra định nghĩa tồn tại (SELECT FROM word_senses WHERE id = ?)
           - Nếu không tồn tại -> raise HTTPException 404
        2. Build dynamic UPDATE query dựa trên các field được cung cấp
        3. Execute UPDATE statement
        4. Commit transaction
    
    Exception:
        404: Meaning not found - Định nghĩa không tồn tại
    
    Ví dụ:
        PUT /admin/meanings/5
        {
            "definition": "to love, to care for, to pity"
        }
        Response: {"status": "updated"}
    """
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
    """
    DELETE /admin/meanings/{meaning_id}
    
    Xóa một định nghĩa khỏi từ.
    
    Tham số:
        meaning_id (int): ID của định nghĩa trong bảng 'word_senses'
    
    Trả về:
        {"status": "deleted"} - Nếu xóa thành công
    
    Process:
        1. Execute DELETE FROM word_senses WHERE id = ?
        2. Nếu không tìm thấy định nghĩa (deleted = 0) -> raise HTTPException 404
        3. Return status message
    
    Exception:
        404: Meaning not found - Định nghĩa không tồn tại
    
    Chú ý:
        - Đây là operación destructive
        - Nếu là định nghĩa duy nhất của từ -> từ sẽ không có định nghĩa nào
        - Display logic có thể cần check nếu từ có ít nhất 1 định nghĩa
    """
    deleted = execute("DELETE FROM word_senses WHERE id = ?", [meaning_id])
    if deleted == 0:
        raise HTTPException(status_code=404, detail="Meaning not found")
    return {"status": "deleted"}


@app.post("/admin/words/{word_id}/examples", response_model=ExampleOut)
def admin_add_example(word_id: int, payload: ExampleCreate):
    """
    POST /admin/words/{word_id}/examples
    
    Thêm một ví dụ sử dụng mới cho một từ.
    
    Tham số:
        word_id (int): ID của từ
        payload (ExampleCreate): Object chứa:
                                - example_text: Nội dung ví dụ (required)
    
    Trả về:
        ExampleOut: Object của ví dụ vừa tạo bao gồm:
                   - id: ID của ví dụ
                   - example_text: Nội dung ví dụ
    
    Process:
        1. Kiểm tra từ tồn tại (SELECT FROM words WHERE id = ?)
           - Nếu không tồn tại -> raise HTTPException 404
        2. INSERT vào bảng 'word_examples' với (word_id, example_text)
        3. Commit transaction
        4. Return ExampleOut object
    
    Exception:
        404: Word not found - Từ không tồn tại
    
    Ví dụ:
        POST /admin/words/1/examples
        {
            "example_text": "Tôi thương anh ấy rất nhiều"
        }
        Response:
        {
            "id": 10,
            "example_text": "Tôi thương anh ấy rất nhiều"
        }
    """
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
    """
    PUT /admin/examples/{example_id}
    
    Cập nhật một ví dụ sử dụng của từ.
    
    Tham số:
        example_id (int): ID của ví dụ trong bảng 'word_examples'
        payload (ExampleUpdate): Object chứa:
                                - example_text: Nội dung ví dụ mới (optional)
    
    Trả về:
        {"status": "updated"} - Nếu cập nhật thành công
    
    Process:
        1. Kiểm tra ví dụ tồn tại (SELECT FROM word_examples WHERE id = ?)
           - Nếu không tồn tại -> raise HTTPException 404
        2. Build dynamic UPDATE query dựa trên các field được cung cấp
        3. Execute UPDATE statement
        4. Commit transaction
    
    Exception:
        404: Example not found - Ví dụ không tồn tại
    
    Ví dụ:
        PUT /admin/examples/10
        {
            "example_text": "Tôi thương bố mẹ tôi rất nhiều"
        }
        Response: {"status": "updated"}
    """
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
    """
    DELETE /admin/examples/{example_id}
    
    Xóa một ví dụ sử dụng khỏi từ.
    
    Tham số:
        example_id (int): ID của ví dụ trong bảng 'word_examples'
    
    Trả về:
        {"status": "deleted"} - Nếu xóa thành công
    
    Process:
        1. Execute DELETE FROM word_examples WHERE id = ?
        2. Nếu không tìm thấy ví dụ (deleted = 0) -> raise HTTPException 404
        3. Return status message
    
    Exception:
        404: Example not found - Ví dụ không tồn tại
    """
    deleted = execute("DELETE FROM word_examples WHERE id = ?", [example_id])
    if deleted == 0:
        raise HTTPException(status_code=404, detail="Example not found")
    return {"status": "deleted"}


@app.get("/admin/synonyms", response_model=List[SynonymOut])
def admin_list_synonyms(limit: int = 200, offset: int = 0):
    """
    GET /admin/synonyms
    
    Lấy danh sách tất cả các quan hệ từ đồng nghĩa (dành cho admin).
    
    Tham số:
        limit (int): Số lượng kết quả mỗi trang (default: 200, max: tự định)
        offset (int): Vị trí bắt đầu (để phân trang, default: 0)
    
    Trả về:
        List[SynonymOut]: Danh sách các từ đồng nghĩa bao gồm:
                         - id: ID của quan hệ đồng nghĩa
                         - word_id: ID của từ gốc
                         - word: Tên của từ gốc
                         - synonym_word_id: ID của từ đồng nghĩa
                         - synonym_word: Tên của từ đồng nghĩa
                         - intensity: Mức độ tương tự (1-10, 10 là giống nhất)
                         - frequency: Tần suất sử dụng
                         - note: Ghi chú thêm
    
    Process:
        1. Query bảng 'synonyms' với JOIN bảng 'words' (2 lần - cho từ gốc và từ đồng nghĩa)
        2. Sắp xếp theo id DESC (mới nhất trước)
        3. Áp dụng LIMIT và OFFSET để phân trang
    
    Ví dụ:
        GET /admin/synonyms?limit=10&offset=0
        Response:
        [
            {
                "id": 1,
                "word_id": 1,
                "word": "thương",
                "synonym_word_id": 2,
                "synonym_word": "yêu",
                "intensity": 8,
                "frequency": 1,
                "note": "more emotional"
            },
            ...
        ]
    """
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
    """
    POST /admin/synonyms
    
    Thêm một quan hệ từ đồng nghĩa (tạo cặp từ đồng nghĩa).
    
    Tham số:
        word_id (int): ID của từ gốc (query parameter)
        payload (SynonymCreate): Object chứa:
                                - word: Tên từ đồng nghĩa (required)
                                - intensity: Mức độ tương tự 1-10 (optional)
                                - frequency: Tần suất sử dụng (optional)
                                - note: Ghi chú thêm (optional)
    
    Trả về:
        {"status": "created"} - Nếu tạo thành công
    
    Process:
        1. Gọi _get_or_create_word_id() để lấy hoặc tạo từ đồng nghĩa
           - Nếu từ đó chưa tồn tại -> tạo từ mới
           - Nếu tồn tại -> lấy ID của nó
        2. INSERT vào bảng 'synonyms' với:
           - word_id: từ gốc
           - synonym_word_id: từ đồng nghĩa vừa tạo/lấy
           - intensity: mức độ tương tự
           - frequency: tần suất
           - note: ghi chú
        3. Commit transaction
    
    Ví dụ:
        POST /admin/synonyms?word_id=1
        {
            "word": "yêu",
            "intensity": 8,
            "frequency": 1,
            "note": "more emotional"
        }
        Response: {"status": "created"}
    """
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
    """
    PUT /admin/synonyms/{synonym_id}
    
    Cập nhật một quan hệ từ đồng nghĩa.
    
    Tham số:
        synonym_id (int): ID của quan hệ đồng nghĩa trong bảng 'synonyms'
        payload (SynonymUpdate): Object chứa các field cần cập nhật (optional):
                                - synonym_word: Tên từ đồng nghĩa mới
                                - intensity: Mức độ tương tự
                                - frequency: Tần suất
                                - note: Ghi chú
    
    Trả về:
        {"status": "updated"} - Nếu cập nhật thành công
    
    Process:
        1. Kiểm tra quan hệ đồng nghĩa tồn tại (SELECT FROM synonyms WHERE id = ?)
           - Nếu không tồn tại -> raise HTTPException 404
        2. Nếu cập nhật 'synonym_word':
           - Gọi _get_or_create_word_id() để lấy hoặc tạo từ mới
        3. Build dynamic UPDATE query dựa trên các field được cung cấp
        4. Execute UPDATE statement
        5. Commit transaction
    
    Exception:
        404: Synonym not found - Quan hệ đồng nghĩa không tồn tại
    
    Ví dụ:
        PUT /admin/synonyms/1
        {
            "intensity": 7,
            "note": "less commonly used"
        }
        Response: {"status": "updated"}
    """
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
    """
    DELETE /admin/synonyms/{synonym_id}
    
    Xóa một quan hệ từ đồng nghĩa.
    
    Tham số:
        synonym_id (int): ID của quan hệ đồng nghĩa trong bảng 'synonyms'
    
    Trả về:
        {"status": "deleted"} - Nếu xóa thành công
    
    Process:
        1. Execute DELETE FROM synonyms WHERE id = ?
        2. Nếu không tìm thấy (deleted = 0) -> raise HTTPException 404
        3. Return status message
    
    Exception:
        404: Synonym not found - Quan hệ không tồn tại
    
    Chú ý:
        - Chỉ xóa quan hệ, không xóa từ đồng nghĩa
        - Từ đồng nghĩa vẫn tồn tại trong từ điển
    """
    deleted = execute("DELETE FROM synonyms WHERE id = ?", [synonym_id])
    if deleted == 0:
        raise HTTPException(status_code=404, detail="Synonym not found")
    return {"status": "deleted"}


@app.get("/admin/proverbs", response_model=List[ProverbOut])
def admin_list_proverbs(limit: int = 200, offset: int = 0):
    """
    GET /admin/proverbs
    
    Lấy danh sách tất cả các tục ngữ/thành ngữ trong từ điển (dành cho admin).
    
    Tham số:
        limit (int): Số lượng kết quả mỗi trang (default: 200)
        offset (int): Vị trí bắt đầu (để phân trang, default: 0)
    
    Trả về:
        List[ProverbOut]: Danh sách các tục ngữ bao gồm:
                         - id: ID của tục ngữ
                         - word_id: ID của từ liên quan
                         - word: Tên của từ liên quan
                         - phrase: Cụm từ/tục ngữ
                         - meaning: Ý nghĩa của tục ngữ
                         - usage: Cách sử dụng/ngữ cảnh
    
    Process:
        1. Query bảng 'proverbs' với JOIN bảng 'words'
        2. Sắp xếp theo id DESC (mới nhất trước)
        3. Áp dụng LIMIT và OFFSET để phân trang
    
    Ví dụ:
        GET /admin/proverbs?limit=10
        Response:
        [
            {
                "id": 1,
                "word_id": 1,
                "word": "thương",
                "phrase": "thương người như thương thân",
                "meaning": "to love others as much as yourself",
                "usage": "@phrase about compassion"
            },
            ...
        ]
    """
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
    """
    POST /admin/proverbs
    
    Thêm một tục ngữ/thành ngữ liên quan đến một từ.
    
    Tham số:
        word_id (int): ID của từ liên quan (query parameter)
        payload (ProverbCreate): Object chứa:
                                - phrase: Cụm từ/tục ngữ (required)
                                - meaning: Ý nghĩa (required)
                                - usage: Cách sử dụng/ngữ cảnh (required)
    
    Trả về:
        {"status": "created"} - Nếu tạo thành công
    
    Process:
        1. INSERT vào bảng 'proverbs' với (word_id, phrase, meaning, usage)
        2. Không cần check word_id tồn tại hay không
    
    Ví dụ:
        POST /admin/proverbs?word_id=1
        {
            "phrase": "thương người như thương thân",
            "meaning": "@to love others like yourself",
            "usage": "@used when teaching about compassion"
        }
        Response: {"status": "created"}
    """
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
    """
    PUT /admin/proverbs/{proverb_id}
    
    Cập nhật một tục ngữ/thành ngữ.
    
    Tham số:
        proverb_id (int): ID của tục ngữ trong bảng 'proverbs'
        payload (ProverbUpdate): Object chứa các field cần cập nhật (optional):
                                - phrase: Cụm từ/tục ngữ
                                - meaning: Ý nghĩa
                                - usage: Cách sử dụng
    
    Trả về:
        {"status": "updated"} - Nếu cập nhật thành công
    
    Process:
        1. Kiểm tra tục ngữ tồn tại (SELECT FROM proverbs WHERE id = ?)
           - Nếu không tồn tại -> raise HTTPException 404
        2. Build dynamic UPDATE query dựa trên các field được cung cấp
        3. Execute UPDATE statement
        4. Commit transaction
    
    Exception:
        404: Proverb not found - Tục ngữ không tồn tại
    
    Ví dụ:
        PUT /admin/proverbs/1
        {
            "meaning": "@to love and care for others like yourself"
        }
        Response: {"status": "updated"}
    """
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
    """
    DELETE /admin/proverbs/{proverb_id}
    
    Xóa một tục ngữ/thành ngữ.
    
    Tham số:
        proverb_id (int): ID của tục ngữ trong bảng 'proverbs'
    
    Trả về:
        {"status": "deleted"} - Nếu xóa thành công
    
    Process:
        1. Execute DELETE FROM proverbs WHERE id = ?
        2. Nếu không tìm thấy (deleted = 0) -> raise HTTPException 404
        3. Return status message
    
    Exception:
        404: Proverb not found - Tục ngữ không tồn tại
    """
    deleted = execute("DELETE FROM proverbs WHERE id = ?", [proverb_id])
    if deleted == 0:
        raise HTTPException(status_code=404, detail="Proverb not found")
    return {"status": "deleted"}


@app.post("/admin/topics")
def admin_create_topic(payload: TopicCreate):
    """
    POST /admin/topics
    
    Tạo một topic/chuyên đề mới.
    
    Tham số:
        payload (TopicCreate): Object chứa:
                              - name: Tên topic (required, không được rỗng)
                              - description: Mô tả topic (optional)
                              - icon: Icon/emoji của topic (optional)
    
    Trả về:
        {"status": "created", "id": <topic_id>} - Nếu tạo thành công
    
    Process:
        1. Validate: name phải không trống sau khi trim
           - Nếu trống -> raise HTTPException 400
        2. INSERT vào bảng 'topics' với (name stripped, description, icon)
        3. Commit transaction
        4. Return object với status và id của topic vừa tạo
    
    Exception:
        400: Topic name is required - Tên topic bắt buộc
    
    Ví dụ:
        POST /admin/topics
        {
            "name": "Hoạt động hàng ngày",
            "description": "Các từ liên quan đến hoạt động hàng ngày",
            "icon": "🏠"
        }
        Response: {"status": "created", "id": 5}
    """
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
    """
    DELETE /admin/topics/{topic_id}
    
    Xóa một topic/chuyên đề.
    
    Tham số:
        topic_id (int): ID của topic trong bảng 'topics'
    
    Trả về:
        {"status": "deleted"} - Nếu xóa thành công
    
    Process:
        1. Execute DELETE FROM topics WHERE id = ?
        2. Nếu không tìm thấy (deleted = 0) -> raise HTTPException 404
        3. Return status message
        4. Chú ý: Bảng 'word_topics' sẽ tự động xóa records CASCADE nếu được config
    
    Exception:
        404: Topic not found - Topic không tồn tại
    
    Ví dụ:
        DELETE /admin/topics/5
        Response: {"status": "deleted"}
    """
    deleted = execute("DELETE FROM topics WHERE id = ?", [topic_id])
    if deleted == 0:
        raise HTTPException(status_code=404, detail="Topic not found")
    return {"status": "deleted"}


@app.post("/admin/topics/{topic_id}/words/{word_id}")
def admin_add_word_to_topic(topic_id: int, word_id: int):
    """
    POST /admin/topics/{topic_id}/words/{word_id}
    
    Gán một từ vào một topic/chuyên đề.
    
    Tham số:
        topic_id (int): ID của topic
        word_id (int): ID của từ
    
    Trả về:
        {"status": "created"} - Nếu gán thành công
    
    Process:
        1. Kiểm tra topic tồn tại (SELECT FROM topics WHERE id = ?)
           - Nếu không tồn tại -> raise HTTPException 404 "Topic not found"
        2. Kiểm tra từ tồn tại (SELECT FROM words WHERE id = ?)
           - Nếu không tồn tại -> raise HTTPException 404 "Word not found"
        3. INSERT vào bảng 'word_topics' với (word_id, topic_id)
           - Sử dụng INSERT OR IGNORE để tránh duplicate entry (idempotent)
        4. Commit transaction
    
    Exception:
        404: Topic not found - Topic không tồn tại
        404: Word not found - Từ không tồn tại
    
    Ví dụ:
        POST /admin/topics/5/words/1
        Response: {"status": "created"}
        
        # Nếu gọi lần 2 với cùng topic_id và word_id -> vẫn return created
        # (không lỗi nhờ INSERT OR IGNORE)
    """
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
    """
    DELETE /admin/topics/{topic_id}/words/{word_id}
    
    Bỏ gán một từ khỏi một topic/chuyên đề.
    
    Tham số:
        topic_id (int): ID của topic
        word_id (int): ID của từ
    
    Trả về:
        {"status": "deleted"} - Nếu bỏ gán thành công
    
    Process:
        1. Execute DELETE FROM word_topics WHERE topic_id = ? AND word_id = ?
        2. Nếu không tìm thấy quan hệ (deleted = 0) -> raise HTTPException 404
        3. Return status message
    
    Exception:
        404: Word not in topic - Từ không thuộc topic này
    
    Ví dụ:
        DELETE /admin/topics/5/words/1
        Response: {"status": "deleted"}
    """
    deleted = execute(
        "DELETE FROM word_topics WHERE topic_id = ? AND word_id = ?",
        [topic_id, word_id],
    )
    if deleted == 0:
        raise HTTPException(status_code=404, detail="Word not in topic")
    return {"status": "deleted"}
