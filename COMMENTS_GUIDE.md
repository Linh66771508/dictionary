# 📚 Hướng Dẫn Hiểu Code - Từ Điển Tiếng Việt

Đây là bản tóm tắt chú thích chi tiết giúp bạn dễ hiểu code dự án **Từ Điển Tiếng Việt**.

---

## 🔧 BACKEND (Python - FastAPI)

### ⚙️ Cấu Trúc Backend
```
backend/
├── requirements.txt          # Thư viện Python (fastapi, uvicorn, psycopg2, ...)
├── schema_sqlite.sql         # Cấu trúc database (SQLite)
├── schema_postgres.sql       # Cấu trúc database (PostgreSQL)
└── app/
    ├── main.py               # Máy chủ API (FastAPI)
    └── db.py                 # Hàm quản lý database
```

### 📦 requirements.txt - Danh Sách Thư Viện
```
fastapi==0.111.0             # Framework tạo API
uvicorn[standard]==0.30.1    # Máy chủ web chạy FastAPI
python-dotenv==1.0.1         # Đọc file .env
psycopg2-binary==2.9.9       # Driver PostgreSQL
```

### 🗄️ Database Schema (Cấu Trúc Bảng)

#### Bảng `words` - Từ vựng
```sql
CREATE TABLE words (
  id INTEGER PRIMARY KEY,
  word TEXT NOT NULL UNIQUE,      -- Từ (ví dụ: "thương")
  pronunciation TEXT,             -- Phát âm
  part_of_speech TEXT,            -- Loại từ (danh từ, động từ, ...)
  frequency TEXT,                 -- Tần suất (thường, hiếm, ...)
  register TEXT,                  -- Mức độ (lịch sử, hiện đại, ...)
  etymology TEXT,                 -- Nguồn gốc
  created_at TIMESTAMP,           -- Ngày tạo
  updated_at TIMESTAMP            -- Ngày cập nhật
);
```
**Ví dụ**:
| id | word  | pronunciation | part_of_speech | frequency | register | etymology |
|----|-------|---------------|-----------------|-----------|----------|-----------|
| 1  | thương | thương       | động từ         | thường    | hiện đại | từ Hán   |
| 2  | yêu    | yêu          | động từ         | thường    | hiện đại | tiếng Việt|

#### Bảng `word_senses` - Định nghĩa
```sql
CREATE TABLE word_senses (
  id INTEGER PRIMARY KEY,
  word_id INTEGER NOT NULL,       -- ID từ (tham chiếu words)
  sense_order INTEGER NOT NULL,   -- Thứ tự (1, 2, 3, ...)
  definition TEXT NOT NULL,       -- Định nghĩa chi tiết
  FOREIGN KEY(word_id) REFERENCES words(id) ON DELETE CASCADE
);
```
**Ví dụ**:
| id | word_id | sense_order | definition |
|----|---------|-------------|-----------|
| 10 | 1       | 1           | Cảm giác đau buồn khi mất người yêu |
| 11 | 1       | 2           | Lo lắng, quan tâm |

#### Bảng `word_examples` - Ví dụ sử dụng
```sql
CREATE TABLE word_examples (
  id INTEGER PRIMARY KEY,
  word_id INTEGER NOT NULL,       -- ID từ
  example_text TEXT NOT NULL,     -- Câu ví dụ
  FOREIGN KEY(word_id) REFERENCES words(id) ON DELETE CASCADE
);
```
**Ví dụ**: "Tôi thương em bằng trái tim"

#### Bảng `topics` - Chuyên đề
```sql
CREATE TABLE topics (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,             -- Tên (ví dụ: "Thực vật")
  description TEXT,               -- Mô tả
  icon TEXT                       -- Biểu tượng (🌿, 🐕, ...)
);
```

#### Bảng `word_topics` - Quan hệ từ ↔ chuyên đề
```sql
CREATE TABLE word_topics (
  word_id INTEGER NOT NULL,       -- ID từ
  topic_id INTEGER NOT NULL,      -- ID chuyên đề
  PRIMARY KEY(word_id, topic_id),
  FOREIGN KEY(word_id) REFERENCES words(id) ON DELETE CASCADE,
  FOREIGN KEY(topic_id) REFERENCES topics(id) ON DELETE CASCADE
);
```

#### Bảng `synonyms` - Từ đồng nghĩa
```sql
CREATE TABLE synonyms (
  id INTEGER PRIMARY KEY,
  word_id INTEGER NOT NULL,       -- ID từ gốc
  synonym_word_id INTEGER NOT NULL,  -- ID từ đồng nghĩa
  intensity INTEGER,              -- Mức độ tương tự (1-5)
  frequency TEXT,                 -- Tần suất
  note TEXT,                      -- Ghi chú
  FOREIGN KEY(word_id) REFERENCES words(id) ON DELETE CASCADE,
  FOREIGN KEY(synonym_word_id) REFERENCES words(id) ON DELETE NO ACTION
);
```

#### Bảng `proverbs` - Thành ngữ/Tục ngữ
```sql
CREATE TABLE proverbs (
  id INTEGER PRIMARY KEY,
  word_id INTEGER NOT NULL,       -- ID từ liên quan
  phrase TEXT NOT NULL,           -- Thành ngữ (ví dụ: "Thương tích lòng")
  meaning TEXT,                   -- Ý nghĩa
  usage TEXT,                     -- Cách sử dụng
  FOREIGN KEY(word_id) REFERENCES words(id) ON DELETE CASCADE
);
```

#### Bảng `related_words` - Từ liên quan
```sql
CREATE TABLE related_words (
  id INTEGER PRIMARY KEY,
  word_id INTEGER NOT NULL,       -- ID từ
  related_word_id INTEGER NOT NULL,  -- ID từ liên quan
  FOREIGN KEY(word_id) REFERENCES words(id) ON DELETE CASCADE,
  FOREIGN KEY(related_word_id) REFERENCES words(id) ON DELETE NO ACTION
);
```

### 🔌 `backend/app/db.py` - Quản Lý Database

#### Các hàm chính:
```python
get_conn()              # Kết nối đến database (SQLite hoặc PostgreSQL)
init_db()               # Khởi tạo bảng lần đầu (chạy lần 1 khi startup)
query_all(sql, params)  # Lấy nhiều hàng từ database
query_one(sql, params)  # Lấy một hàng từ database
execute(sql, params)    # Thực hiện UPDATE/DELETE
execute_insert(sql, params)  # Thêm dữ liệu mới (INSERT) và lấy ID
```

#### Cách sử dụng:
```python
# Lấy tất cả từ
rows = query_all("SELECT * FROM words")

# Tìm kiếm từ có chứa 'th'
rows = query_all("SELECT * FROM words WHERE word LIKE ?", ['%th%'])

# Lấy một từ theo ID
word = query_one("SELECT * FROM words WHERE id = ?", [1])

# Cập nhật từ
affected = execute("UPDATE words SET part_of_speech = ? WHERE id = ?", ['động từ', 1])

# Thêm từ mới (lấy ID)
new_id = execute_insert(
    "INSERT INTO words (word, pronunciation, part_of_speech) VALUES (?, ?, ?)",
    ['hoa', 'hoa', 'danh từ']
)
```

### 🚀 `backend/app/main.py` - API Endpoints

#### Các Endpoint chính:
```
GET  /health                      # Kiểm tra server hoạt động
GET  /topics                      # Lấy danh sách chủ đề
GET  /topics/{topic_id}/words     # Lấy từ trong chủ đề
GET  /words/search?q={keyword}    # Tìm kiếm từ
GET  /words/id/{word_id}          # Lấy chi tiết từ
```

#### Models (Pydantic Classes):
```python
TopicOut        # Thông tin chủ đề
WordSummary     # Thông tin tóm tắt từ
WordDetail      # Thông tin đầy đủ từ
MeaningOut      # Một định nghĩa
ExampleOut      # Một ví dụ
SynonymOut      # Một từ đồng nghĩa
ProverbOut      # Một thành ngữ
AdminStats      # Thống kê (tổng số từ, đồng nghĩa, ...)
```

#### Ví dụ Response:

**GET /topics**
```json
[
  {
    "id": 1,
    "name": "Thực vật",
    "description": "Các từ về cây, hoa, lá",
    "icon": "🌿",
    "word_count": 45
  }
]
```

**GET /words/id/1**
```json
{
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
  "examples": [{"id": 20, "example_text": "Tôi thương em bằng trái tim"}],
  "synonyms": [{"id": 30, "word": "thương", "synonym_word": "yêu", "intensity": 4}],
  "proverbs": [{"id": 40, "phrase": "Thương tích lòng", "meaning": "..."}],
  "topics": [{"id": 2, "name": "Động vật"}]
}
```

### 💾 Cấu hình Database

Tạo file `.env` trong folder `backend/`:
```env
# Nếu dùng SQLite (phát triển cục bộ)
SQLITE_DB_PATH=./data/dictionary.db
DB_DRIVER=sqlite

# HOẶC nếu dùng PostgreSQL (production)
DATABASE_URL=postgres://user:password@localhost:5432/dictionary
DB_DRIVER=postgres
```

### 🚢 Cách chạy Backend

```bash
# 1. Cài đặt dependencies
cd backend
pip install -r requirements.txt

# 2. Chạy server
uvicorn app.main:app --reload
# Server chạy tại: http://localhost:8000

# 3. Test API
curl http://localhost:8000/health
curl http://localhost:8000/topics

# 4. Xem API documentation
# Mở browser: http://localhost:8000/docs
```

---

## 📱 APP NGƯỜI DÙNG (Flutter - Dart)
**Folder**: `dictionary_app/lib/`

### 📂 Cấu Trúc Thư Mục

```
lib/
├── main.dart              # Điểm bắt đầu - khởi chạy app
├── config.dart            # Cấu hình (địa chỉ server)
├── models/                # Lớp dữ liệu (giống Backend Models)
│   ├── word_summary.dart      # Thông tin tóm tắt từ
│   ├── word_detail.dart       # Thông tin đầy đủ từ
│   ├── topic.dart             # Chủ đề
│   ├── meaning.dart           # Nghĩa của từ
│   ├── example.dart           # Ví dụ
│   ├── synonym.dart           # Từ đồng nghĩa
│   └── proverb.dart          # Thành ngữ
├── services/              # Giao tiếp với API
│   └── api_client.dart        # Gửi request đến server
├── screens/               # Các màn hình chính
│   ├── home_screen.dart       # Trang chủ (tìm kiếm, chủ đề)
│   ├── topic_screen.dart      # Danh sách từ trong chủ đề
│   └── word_detail_screen.dart # Chi tiết từ
└── widgets/               # Các thành phần UI nhỏ
    ├── search_bar.dart        # Thanh tìm kiếm
    └── topic_card.dart        # Thẻ hiển thị chủ đề
```

### 🔄 Luồng Ứng Dụng

1. **main.dart** → Khởi chạy app
2. **HomeScreen** → Hiển thị chủ đề + thanh tìm kiếm
3. **SearchBar** → Người dùng gõ từ
4. **ApiClient** → Gửi request `/words/search` đến backend
5. **WordDetailScreen** → Hiển thị chi tiết từ

### 📝 Models (Dart Classes)

```dart
// Từ tóm tắt
WordSummary {
  int id;
  String word;
  String? partOfSpeech;  // Loại từ
  String? shortDef;       // Định nghĩa ngắn
}

// Chi tiết từ
WordDetail {
  int id;
  String word;
  String? pronunciation;  // Phát âm
  String? etymology;      // Nguồn gốc
  List<Meaning> meanings;    // Nghĩa
  List<Example> examples;    // Ví dụ
  List<Synonym> synonyms;    // Từ đồng nghĩa
  List<Proverb> proverbs;    // Thành ngữ liên quan
  List<Topic> topics;        // Chủ đề
}

// Chủ đề
Topic {
  int id;
  String name;
  String? description;
  String? icon;       // Emoji
  int wordCount;      // Số từ trong chủ đề
}
```

### 🎨 Stateful vs Stateless Widgets

- **StatefulWidget** (HomeScreen): Widget có trạng thái thay đổi (danh sách gợi ý, v.v.)
- **StatelessWidget** (TopicCard): Widget tĩnh, không thay đổi

---

## 👨‍💼 APP QUẢN TRỊ (Flutter - Dart)
**Folder**: `dictionary_admin_app/lib/`

### 📂 Cấu Trúc Tương Tự

```
lib/
├── main.dart              # Khởi chạy app quản trị
├── config.dart            # Cấu hình
├── models/                # Dữ liệu
│   ├── admin_stats.dart       # Thống kê tổng quan
│   ├── word_summary.dart      # Từ
│   └── ... (giống app người dùng)
├── services/
│   └── api_client.dart        # CRUD (Create, Read, Update, Delete)
├── screens/
│   ├── admin_shell.dart           # Khung chính (sidebar)
│   ├── dashboard_screen.dart      # Trang tổng quan
│   ├── dictionary_management_screen.dart  # Quản lý từ
│   ├── synonym_management_screen.dart     # Quản lý đồng nghĩa
│   ├── proverb_management_screen.dart     # Quản lý thành ngữ
│   └── topic_management_screen.dart       # Quản lý chủ đề
└── widgets/               # Thành phần UI
```

### 🖥️ Màn Hình Quản Trị

1. **AdminShell** → Khung chính với sidebar
   - NavigationRail (lề trái) để chuyển giữa các trang
   
2. **DashboardScreen** → Thống kê (tổng từ, đồng nghĩa, v.v.)

3. **Các quản lý** → CRUD (thêm, sửa, xóa):
   - DictionaryManagementScreen  
   - SynonymManagementScreen
   - ProverbManagementScreen
   - TopicManagementScreen

---

## 🔌 API Client (Giao Tiếp với Backend)

### Dictionary_App API Calls

```dart
// Lấy chủ đề
api.fetchTopics()

// Tìm kiếm từ
api.searchWords("từ")

// Lấy chi tiết từ
api.getWordById(id)

// Lấy từ trong chủ đề
api.getTopicWords(topicId)
```

### Admin_App API Calls (Thêm CRUD)

```dart
// Thống kê
api.fetchStats()

// Danh sách từ
api.listWords(query: "từ")

// Tạo mới
api.createWord(word, partOfSpeech, meanings, examples)

// Cập nhật
api.updateWord(id, data)

// Xóa
api.deleteWord(id)

// Quản lý nghĩa, ví dụ, v.v.
api.addMeaning()
api.deleteSynonym()
...
```

---

## 🗂️ JSON ↔️ Dart (Chuyển Đổi Dữ Liệu)

**Từ Server (JSON):**
```json
{
  "id": 1,
  "word": "yêu",
  "part_of_speech": "động từ",
  "meanings": [
    {"id": 1, "definition": "thích", "sense_order": 1}
  ]
}
```

**Thành Dart Object:**
```dart
final wordData = jsonDecode(jsonString); // Chuyển JSON thành Map
final wordDetail = WordDetail.fromJson(wordData); // Chuyển Map thành Object
```

---

## 🔑 Các Khái Niệm Quan Trọng

### StatefulWidget vs StatelessWidget
- **Stateful**: Có `setState()` - dùng khi dữ liệu thay đổi (danh sách gợi ý)
- **Stateless**: Tĩnh - dùng khi dữ liệu không thay đổi (thẻ chủ đề)

### Future & async/await
```dart
// Gọi hàm bất đồng bộ (không chờ xong mới chạy tiếp)
Future<WordDetail> getWord() async {
  return await api.getWordById(1);
}
```

### FutureBuilder
```dart
FutureBuilder<List<Topic>>(
  future: api.fetchTopics(),  // Chờ kết quả từ server
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();  // Đang tải
    }
    final topics = snapshot.data;  // Dữ liệu đã tải
    return ListView(...);
  },
)
```

---

## 📊 Sơ Đồ Tương Tác

```
┌─────────────────────────────────────────────────────────┐
│              NGƯỜI DÙNG                                  │
└─────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────┐
│   Dictionary App (Flutter)                              │
│  ❤︎ HomeScreen (tìm kiếm, chủ đề)                       │
│  ❤︎ WordDetailScreen (chi tiết)                        │
│  ❤︎ TopicScreen (từ theo chủ đề)                       │
└─────────────────────────────────────────────────────────┘
                    ↓ (HTTP Request)
┌─────────────────────────────────────────────────────────┐
│   Backend API (FastAPI - Python)                        │
│  📊 /topics/ → Chủ đề                                    │
│  📊 /words/search → Tìm kiếm                            │
│  📊 /words/id/{id} → Chi tiết                           │
└─────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────┐
│   Database (SQLite)                                     │
│  📦 topics, words, meanings, examples, synonyms, ...    │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 Tóm Tắt Nhanh

| Phần | Chức Năng | Ngôn Ngữ |
|------|-----------|---------|
| Backend | Lưu trữ dữ liệu, cung cấp API | Python (FastAPI) |
| App Người Dùng | Tra cứu từ vựng | Dart (Flutter) |
| App Quản Trị | Quản lý dữ liệu từ điển | Dart (Flutter) |
| Database | Lưu trữ từ, nghĩa, chủ đề | SQLite |

---

**Chúc bạn học tập hiệu quả! 🎓**
