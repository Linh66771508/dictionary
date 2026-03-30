# 📚 Hướng Dẫn Backend Chi Tiết - Cho Người Mới

> Tài liệu này mô tả chi tiết **từng phần của backend** (Python + FastAPI + Database), giúp bạn hiểu cách mã hoạt động và cách mở rộng nó.

---

## 🎯 Tổng Quan Backend

### Backend là gì?
**Backend** là máy chủ (server) chứa:
1. **Tất cả dữ liệu** từ điển (từ, định nghĩa, ví dụ, ...)
2. **API endpoints** (các "đường dẫn" để các ứng dụng khác gọi để lấy dữ liệu)
3. **Xử lý logic** (tìm kiếm, lọc, sắp xếp, ...)

### Từ điển gồm các phần:
- **App người dùng** → Gọi backend để lấy dữ liệu → Hiển thị cho người dùng
- **App admin** → Gọi backend để thêm/sửa/xóa dữ liệu

### Cấu trúc backend folder
```
backend/
├── requirements.txt              # Danh sách thư viện Python cần dùng
├── schema_sqlite.sql             # Cấu trúc database (nếu dùng SQLite)
├── schema_postgres.sql           # Cấu trúc database (nếu dùng PostgreSQL)
└── app/
    ├── main.py                   # Máy chủ API + API endpoints
    └── db.py                     # Hàm kết nối & thao tác database
```

---

## 📦 Bước 1: requirements.txt - Thư viện Cần Dùng

### File này chứa danh sách:
```
fastapi==0.111.0              # Framework tạo API web
uvicorn[standard]==0.30.1     # Máy chủ web chạy FastAPI
python-dotenv==1.0.1          # Đọc file .env (biến cấu hình)
psycopg2-binary==2.9.9        # Driver kết nối PostgreSQL
```

### Mỗi hàng là một thư viện (package):
- **fastapi**: Dùng để tạo API endpoints (đường dẫn `/topics`, `/words/search`, ...)
- **uvicorn**: Máy chủ web - khi chạy lệnh `uvicorn app.main:app`, nó sẽ bắt đầu máy chủ FastAPI
- **python-dotenv**: Cho phép đọc file `.env` chứa biến môi trường (DATABASE_URL, SQLITE_DB_PATH, ...)
- **psycopg2-binary**: Driver PostgreSQL - dùng để kết nối đến PostgreSQL database nếu sử dụng PostgreSQL

### Cách cài đặt:
```bash
pip install -r requirements.txt
```

---

## 🗄️ Bước 2: Database Schema - Cấu Trúc Dữ Liệu

### Backend hỗ trợ hai loại database:
1. **SQLite** (file `schema_sqlite.sql`) - Dùng cho phát triển cục bộ, nhỏ gọn
2. **PostgreSQL** (file `schema_postgres.sql`) - Dùng cho production, mạnh mẽ

### Cấu trúc bảng (Tables)

#### 1. **Bảng `words` - Chứa các từ vựng**
```sql
CREATE TABLE IF NOT EXISTS words (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  word TEXT NOT NULL UNIQUE,           -- Từ tiếng Việt (ví dụ: "thương")
  pronunciation TEXT,                  -- Cách phát âm (ví dụ: "thương")
  part_of_speech TEXT,                 -- Loại từ (ví dụ: "danh từ", "động từ")
  frequency TEXT,                      -- Tần suất (ví dụ: "thường", "hiếm")
  register TEXT,                       -- Mức độ trang trọng (ví dụ: "lịch sử", "hiện đại")
  etymology TEXT,                      -- Nguồn gốc (ví dụ: "từ Hán Việt")
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,  -- Ngày tạo
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP   -- Ngày sửa lần cuối
);
```
**Ví dụ dữ liệu:**
```
id | word    | pronunciation | part_of_speech | frequency | register | etymology
1  | thương  | thương        | động từ         | thường    | hiện đại | từ Hán
2  | yêu     | yêu           | động từ         | thường    | hiện đại | tiếng Việt
3  | hoa     | hoa           | danh từ         | thường    | hiện đại | tiếng Việt
```

#### 2. **Bảng `word_senses` - Định nghĩa của từ**
```sql
CREATE TABLE IF NOT EXISTS word_senses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  word_id INTEGER NOT NULL,            -- ID từ (tham chiếu bảng words)
  sense_order INTEGER NOT NULL,        -- Thứ tự định nghĩa (1, 2, 3, ...)
  definition TEXT NOT NULL,            -- Định nghĩa chi tiết
  FOREIGN KEY(word_id) REFERENCES words(id) ON DELETE CASCADE
);
```
**Ví dụ dữ liệu:**
```
id | word_id | sense_order | definition
10 | 1       | 1           | Cảm giác đau buồn khi mất mất người/vật yêu
11 | 1       | 2           | Lo lắng, quan tâm
12 | 2       | 1           | Có tình cảm sâu sắc với ai/cái gì
13 | 2       | 2           | Thích thú (ví dụ: yêu thể thao)
```
**Lưu ý**: Một từ có thể có nhiều định nghĩa khác nhau, thứ tự được lưu trong `sense_order`

#### 3. **Bảng `word_examples` - Ví dụ sử dụng từ**
```sql
CREATE TABLE IF NOT EXISTS word_examples (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  word_id INTEGER NOT NULL,            -- ID từ
  example_text TEXT NOT NULL,          -- Câu ví dụ
  FOREIGN KEY(word_id) REFERENCES words(id) ON DELETE CASCADE
);
```
**Ví dụ dữ liệu:**
```
id | word_id | example_text
20 | 1       | "Tôi thương em bằng trái tim"
21 | 1       | "Mẹ thương con rất nhiều"
22 | 2       | "Anh yêu em từ lâu"
23 | 2       | "Tôi yêu đọc sách"
```

#### 4. **Bảng `topics` - Chuyên đề/Danh mục**
```sql
CREATE TABLE IF NOT EXISTS topics (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,                  -- Tên chuyên đề (ví dụ: "Thực vật")
  description TEXT,                    -- Mô tả chuyên đề
  icon TEXT                            -- Icon/biểu tượng (ví dụ: "🌿")
);
```
**Ví dụ dữ liệu:**
```
id | name      | description              | icon
1  | Thực vật  | Các từ về cây, hoa, lá   | 🌿
2  | Động vật  | Các từ về động vật        | 🐕
3  | Thực phẩm | Các từ về đồ ăn         | 🍎
```

#### 5. **Bảng `word_topics` - Quan hệ từ ↔ Chuyên đề**
```sql
CREATE TABLE IF NOT EXISTS word_topics (
  word_id INTEGER NOT NULL,            -- ID từ
  topic_id INTEGER NOT NULL,           -- ID chuyên đề
  PRIMARY KEY(word_id, topic_id),      -- Không thể có cặp trùng
  FOREIGN KEY(word_id) REFERENCES words(id) ON DELETE CASCADE,
  FOREIGN KEY(topic_id) REFERENCES topics(id) ON DELETE CASCADE
);
```
**Ví dụ dữ liệu:**
```
word_id | topic_id
1       | 2         -- Từ "thương" có chuyên đề "Động vật"
2       | 2         -- Từ "yêu" có chuyên đề "Động vật"
3       | 1         -- Từ "hoa" có chuyên đề "Thực vật"
```
**Lưu ý**: Một từ có thể thuộc nhiều chuyên đề (ví dụ: từ "yêu" có thể vừa ở chuyên đề "Cảm xúc" vừa ở chuyên đề "Động vật")

#### 6. **Bảng `synonyms` - Từ đồng nghĩa**
```sql
CREATE TABLE IF NOT EXISTS synonyms (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  word_id INTEGER NOT NULL,            -- ID từ gốc
  synonym_word_id INTEGER NOT NULL,    -- ID từ đồng nghĩa
  intensity INTEGER,                   -- Mức độ tương tự (1-5, 5 là giống nhất)
  frequency TEXT,                      -- Tần suất sử dụng
  note TEXT,                           -- Ghi chú thêm
  FOREIGN KEY(word_id) REFERENCES words(id) ON DELETE CASCADE,
  FOREIGN KEY(synonym_word_id) REFERENCES words(id) ON DELETE NO ACTION
);
```
**Ví dụ dữ liệu:**
```
id | word_id | synonym_word_id | intensity | frequency | note
30 | 1 (thương) | 2 (yêu)       | 4         | thường   | Ý nghĩa gần nhưng khác tinh tế
31 | 2 (yêu)   | 1 (thương)    | 4         | thường   | Ngược lại
```

#### 7. **Bảng `proverbs` - Thành ngữ/Tục ngữ**
```sql
CREATE TABLE IF NOT EXISTS proverbs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  word_id INTEGER NOT NULL,            -- ID từ liên quan
  phrase TEXT NOT NULL,                -- Thành ngữ (ví dụ: "Thương một người nhiều")
  meaning TEXT,                        -- Ý nghĩa của thành ngữ
  usage TEXT,                          -- Cách sử dụng
  FOREIGN KEY(word_id) REFERENCES words(id) ON DELETE CASCADE
);
```
**Ví dụ dữ liệu:**
```
id | word_id | phrase                    | meaning              | usage
40 | 1       | "Thương tích lòng"        | Để lại sẹo tình cảm  | Dùng trong văn học
41 | 1       | "Thương xuân"             | Tiếc ngày xuân       | Thơ ca
```

#### 8. **Bảng `related_words` - Từ liên quan**
```sql
CREATE TABLE IF NOT EXISTS related_words (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  word_id INTEGER NOT NULL,            -- ID từ
  related_word_id INTEGER NOT NULL,    -- ID từ liên quan
  FOREIGN KEY(word_id) REFERENCES words(id) ON DELETE CASCADE,
  FOREIGN KEY(related_word_id) REFERENCES words(id) ON DELETE NO ACTION
);
```
**Ví dụ dữ liệu:**
```
id | word_id | related_word_id
50 | 3 (hoa) | 1 (thương)      -- Từ "hoa" liên quan đến "thương" (ví dụ: hoa biểu thị tình yêu)
```

---

## 🔌 Bước 3: db.py - Hàm Quản Lý Database

### File này chứa các hàm:

#### 1. **get_conn() - Kết nối Database**
```python
with get_conn() as conn:
    cur = conn.cursor()
    cur.execute("SELECT * FROM words")
    rows = cur.fetchall()
```
**Tác dụng**: Mở kết nối đến database (SQLite hoặc PostgreSQL)
**Đặc điểm**:
- Sử dụng `with` statement (context manager) → tự động đóng kết nối khi kết thúc
- Tránh memory leak (kết nối không bao giờ bị mở mà quên đóng)

#### 2. **query_all(sql, params) - Lấy Nhiều Hàng**
```python
# Ví dụ: Lấy tất cả từ
rows = query_all("SELECT * FROM words")
# Trả về: [{'id': 1, 'word': 'thương', ...}, {'id': 2, 'word': 'yêu', ...}, ...]

# Ví dụ: Tìm kiếm từ có chứa 'th'
rows = query_all("SELECT * FROM words WHERE word LIKE ?", ['%th%'])

# Ví dụ: Lấy các từ từ topic 5
rows = query_all(
    """SELECT w.* FROM words w 
       JOIN word_topics wt ON w.id = wt.word_id 
       WHERE wt.topic_id = ?""",
    [5]
)
```
**Trả về**: List của dictionaries
**Chú ý**: 
- Sử dụng `?` placeholder (SQLite) hoặc `%s` (PostgreSQL) - tự động chuyển đổi
- Không bao giờ string concatenation (nguy hiểm SQL injection)

#### 3. **query_one(sql, params) - Lấy Một Hàng**
```python
# Ví dụ: Lấy từ với ID = 1
word = query_one("SELECT * FROM words WHERE id = ?", [1])
if word:
    print(f"Từ: {word['word']}")
else:
    print("Từ không tồn tại")

# Ví dụ: Đếm tổng số từ
result = query_one("SELECT COUNT(*) AS total FROM words")
total = result['total']
```
**Trả về**: Single dictionary hoặc None
**Dùng khi**: Bạn chỉ cần 1 kết quả (ID cụ thể, COUNT, ...)

#### 4. **execute(sql, params) - Sửa/Xóa Dữ Liệu (UPDATE/DELETE)**
```python
# Ví dụ: Cập nhật loại từ
affected = execute("UPDATE words SET part_of_speech = ? WHERE id = ?", ['động từ', 1])
print(f"Updated {affected} rows")

# Ví dụ: Xóa ví dụ
affected = execute("DELETE FROM word_examples WHERE id = ?", [10])
if affected == 0:
    print("Ví dụ không tồn tại")
```
**Trả về**: Số hàng bị ảnh hưởng (affected rows)
**Tác dụng**: Thực hiện INSERT/UPDATE/DELETE

#### 5. **execute_insert(sql, params) - Thêm Dữ Liệu (INSERT)**
```python
# Ví dụ: Thêm từ mới
new_word_id = execute_insert(
    "INSERT INTO words (word, pronunciation, part_of_speech) VALUES (?, ?, ?)",
    ['hoa', 'hoa', 'danh từ']
)
print(f"New word ID: {new_word_id}")  # Trả về ID của từ vừa thêm

# Ví dụ: Thêm definition mới
new_sense_id = execute_insert(
    "INSERT INTO word_senses (word_id, sense_order, definition) VALUES (?, ?, ?)",
    [new_word_id, 1, 'Bộ phận sinh dục của cây']
)
```
**Trả về**: ID của hàng vừa insert (auto-increment)
**Dùng khi**: Thêm dữ liệu mới và cần ID để sử dụng sau

---

## 🚀 Bước 4: main.py - API Endpoints

### API Endpoint là gì?
**Endpoint** = Một "đường dẫn URL" mà app gọi để lấy hoặc sửa dữ liệu

### Cấu trúc mỗi endpoint:
```python
@app.get("/topics")  # HTTP method (GET/POST/PUT/DELETE) + đường dẫn
def list_topics():   # Tên hàm Python
    """Mô tả endpoint"""
    return [...]     # Trả về dữ liệu JSON
```

### Các Endpoint Chính

#### 1. **GET /health - Kiểm Tra Server Hoạt Động**
```
Request:  GET http://localhost:8000/health
Response: {"status": "ok"}
```
**Dùng để**: Test xem server có chạy không

#### 2. **GET /topics - Lấy Danh Sách Chủ Đề**
```
Request:  GET http://localhost:8000/topics
Response: [
  {
    "id": 1,
    "name": "Thực vật",
    "description": "Các từ về cây, hoa, lá",
    "icon": "🌿",
    "word_count": 45
  },
  {
    "id": 2,
    "name": "Động vật",
    "description": "Các từ về động vật",
    "icon": "🐕",
    "word_count": 30
  }
]
```
**Dùng để**: Hiển thị danh sách chuyên đề trên trang chủ

**Code Python**:
```python
@app.get("/topics", response_model=List[TopicOut])
def list_topics():
    rows = query_all("""
        SELECT t.id, t.name, t.description, t.icon,
               (SELECT COUNT(*) FROM word_topics wt WHERE wt.topic_id = t.id) AS word_count
        FROM topics t
        ORDER BY t.name
    """)
    return rows
```

#### 3. **GET /topics/{topic_id}/words - Lấy Từ Trong Chủ Đề**
```
Request:  GET http://localhost:8000/topics/1/words
Response: [
  {"id": 3, "word": "hoa", "part_of_speech": "danh từ", "short_def": "Bộ phận sinh dục..."},
  {"id": 5, "word": "lá", "part_of_speech": "danh từ", "short_def": "Phần xanh của cây..."}
]
```
**Dùng để**: Khi người dùng click vào chuyên đề "Thực vật", hiển thị tất cả từ trong chuyên đề

**Code Python**:
```python
@app.get("/topics/{topic_id}/words", response_model=List[WordSummary])
def list_topic_words(topic_id: int):
    rows = query_all("""
        SELECT w.id, w.word, w.part_of_speech,
               s.definition AS short_def
        FROM word_topics wt
        JOIN words w ON wt.word_id = w.id
        LEFT JOIN word_senses s ON s.word_id = w.id
        WHERE wt.topic_id = ?
        ORDER BY w.word
    """, [topic_id])
    return rows
```

#### 4. **GET /words/search?q={keyword} - Tìm Kiếm Từ**
```
Request:  GET http://localhost:8000/words/search?q=thương
Response: [
  {"id": 1, "word": "thương", "part_of_speech": "động từ", "short_def": "Cảm giác đau buồn..."},
  {"id": 10, "word": "dạ thương", "part_of_speech": "danh từ", "short_def": "Cây dạ thương"}
]
```
**Dùng để**: Khi người dùng gõ từ vào thanh tìm kiếm

#### 5. **GET /words/id/{word_id} - Lấy Chi Tiết Từ**
```
Request:  GET http://localhost:8000/words/id/1
Response: {
  "id": 1,
  "word": "thương",
  "pronunciation": "thương",
  "part_of_speech": "động từ",
  "frequency": "thường",
  "register": "hiện đại",
  "etymology": "từ Hán",
  "meanings": [
    {"id": 10, "definition": "Cảm giác đau buồn...", "sense_order": 1},
    {"id": 11, "definition": "Lo lắng, quan tâm", "sense_order": 2}
  ],
  "examples": [
    {"id": 20, "example_text": "Tôi thương em bằng trái tim"},
    {"id": 21, "example_text": "Mẹ thương con rất nhiều"}
  ],
  "synonyms": [
    {"id": 30, "word": "thương", "synonym_word": "yêu", "intensity": 4}
  ],
  "proverbs": [
    {"id": 40, "phrase": "Thương tích lòng", "meaning": "Để lại sẹo tình cảm"}
  ],
  "topics": [
    {"id": 2, "name": "Động vật"}
  ]
}
```
**Dùng để**: Khi người dùng click vào một từ, hiển thị tất cả thông tin chi tiết

---

## 🔄 Luồng Hoạt Động (Flow)

### Ví dụ 1: Người dùng tìm kiếm từ "thương"

```
1. user gõ "thương" vào thanh tìm kiếm (app người dùng)
   ↓
2. app gửi HTTP request: GET /words/search?q=thương
   ↓
3. backend nhận request → hàm search_words(q) chạy
   ↓
4. hàm gọi query_all("SELECT * FROM words WHERE word LIKE ?", ['%thương%'])
   ↓
5. db.py kết nối database → execute SQL → lấy dữ liệu
   ↓
6. backend trả về JSON: [{"id": 1, "word": "thương", ...}, ...]
   ↓
7. app người dùng nhận JSON → hiển thị trong list
   ↓
8. user click vào "thương" → gửi request: GET /words/id/1
   ↓
9. backend lấy chi tiết từ gồm tất cả ý nghĩa, ví dụ, đồng nghĩa, ...
   ↓
10. app hiển thị tất cả thông tin chi tiết từ "thương"
```

### Ví dụ 2: Admin thêm từ mới (app admin)

```
1. admin nhập tên từ, định nghĩa, v.v. (app admin)
   ↓
2. app gửi POST request: /admin/words với dữ liệu
   ↓
3. backend nhận request → hàm create_word(word_data) chạy
   ↓
4. hàm gọi:
   - execute_insert("INSERT INTO words ...") → lấy ID từ mới
   - execute_insert("INSERT INTO word_senses ...") → thêm definitions
   - execute_insert("INSERT INTO word_examples ...") → thêm examples
   - ... (thêm synonyms, proverbs, topics, ...)
   ↓
5. db.py thực hiện INSERT SQL
   ↓
6. database lưu dữ liệu mới
   ↓
7. backend trả về {"success": true, "word_id": 100}
   ↓
8. app hiển thị "Thêm từ thành công"
```

---

## 💡 Chú Ý Quan Trọng

### 1. **CORS Middleware**
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],        # Cho phép mọi origin gọi API
    allow_credentials=True,
    allow_methods=["*"],        # Cho phép GET, POST, PUT, DELETE, ...
    allow_headers=["*"],        # Cho phép mọi header
)
```
**Tác dụng**: Cho phép app Flutter (chạy trên máy khác) gọi backend

### 2. **Database Connection**
- **SQLite**: File lưu trên disk (đơn giản, không cần setup)
- **PostgreSQL**: Server database riêng biệt (mạnh mẽ, cho production)
- **Cấu hình**: Trong file `.env`
  ```
  SQLITE_DB_PATH=./data/dictionary.db     # Nếu dùng SQLite
  DATABASE_URL=postgres://user:pass@...   # Nếu dùng PostgreSQL
  DB_DRIVER=postgres                      # Hay "sqlite"
  ```

### 3. **Placeholder SQL**
- **SQLite**: Dùng `?` (ví dụ: `WHERE id = ?`)
- **PostgreSQL**: Dùng `%s` (ví dụ: `WHERE id = %s`)
- **db.py tự động chuyển đổi** qua hàm `_convert_sql()`

### 4. **Foreign Keys**
Bảng con phải tham chiếu đến bảng cha:
- `word_senses.word_id` → `words.id`
- `word_examples.word_id` → `words.id`
- Khi xóa từ (words) → tất cả định nghĩa, ví dụ trong từ cũng bị xóa (CASCADE)

---

## 🚢 Cách Chạy Backend

### 1. Cài đặt thư viện
```bash
cd backend
pip install -r requirements.txt
```

### 2. Chạy máy chủ
```bash
# Chạy trên localhost:8000
uvicorn app.main:app --reload

# Hoặc chạy trên port khác
uvicorn app.main:app --host 0.0.0.0 --port 8080 --reload
```

### 3. Test API
```bash
# Test endpoint /health
curl http://localhost:8000/health

# Lấy danh sách chủ đề
curl http://localhost:8000/topics

# Tìm kiếm từ
curl "http://localhost:8000/words/search?q=thương"

# Lấy chi tiết từ
curl http://localhost:8000/words/id/1
```

### 4. Xem documentation API
```
Mở browser: http://localhost:8000/docs
```
FastAPI tự động tạo Swagger UI để test tất cả endpoints

---

## 📝 Tóm Tắt

| Phần | Tác dụng | Phụ trách |
|------|---------|---------|
| **requirements.txt** | Danh sách thư viện cần cài | Quản lý dependencies |
| **schema_*.sql** | Định nghĩa cấu trúc bảng database | Cấu trúc dữ liệu |
| **db.py** | Hàm kết nối & truy vấn database | Giao tiếp với DB |
| **main.py** | Máy chủ API & endpoints | Cung cấp dữ liệu cho app |

Bạn đã hiểu backend! 🎉
