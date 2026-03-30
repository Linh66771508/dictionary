# 📚 Hướng Dẫn Hiểu Code - Từ Điển Tiếng Việt

Đây là bản tóm tắt chú thích chi tiết giúp bạn dễ hiểu code dự án **Từ Điển Tiếng Việt**.

---

## 🔧 BACKEND (Python - FastAPI)

### `backend/app/db.py` - Quản Lý Database
- **db.py**: Nhóm các hàm quản lý kết nối & thao tác với SQLite
  ```python
  get_conn()        # Kết nối đến database
  init_db()         # Khởi tạo database lần đầu
  query_all()       # Lấy nhiều hàng từ database  
  query_one()       # Lấy một hàng từ database
  execute()         # Thực hiện câu lệnh UPDATE/DELETE
  execute_insert()  # Thêm dữ liệu mới và lấy ID
  ```

### `backend/app/main.py` - API Endpoints
- **main.py**: Máy chủ API - cung cấp đường dẫn (/endpoints) để app gọi
  ```
  /topics/              # Lấy danh sách chủ đề
  /words/search        # Tìm kiếm từ
  /words/id/{id}       # Lấy chi tiết từ
  /topics/{id}/words   # Lấy từ theo chủ đề
  /admin/stats         # Thống kê cho quản trị
  /admin/words         # Quản lý từ
  ```
- **Models (Classes)**: Định nghĩa cấu trúc dữ liệu
  ```
  TopicOut       # Thông tin chủ đề
  WordSummary    # Thông tin tóm tắt từ
  WordDetail     # Thông tin đầy đủ từ
  Meaning        # Nghĩa của từ
  Example        # Ví dụ sử dụng
  Synonym        # Từ đồng nghĩa
  Proverb        # Thành ngữ/Tục ngữ
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
