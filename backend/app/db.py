# ============================================================================
# File: db.py - Quản lý kết nối và thao tác với cơ sở dữ liệu SQLite
# Tác dụng: Cung cấp các function để kết nối, truy vấn và sửa dữ liệu
# ============================================================================

import os
import sqlite3
from contextlib import contextmanager
from typing import Any, Dict, Iterable, List, Optional

from dotenv import load_dotenv

load_dotenv()

# Đường dẫn tới file cơ sở dữ liệu SQLite
DB_PATH = os.getenv("SQLITE_DB_PATH", "./data/dictionary.db")


# Hàm tạo thư mục database nếu chưa tồn tại
def _ensure_db_dir() -> None:
    """
    Tạo thư mục data nếu chưa có để lưu file database.
    
    Tác dụng:
        - Kiểm tra xem thư mục chứa file database có tồn tại không
        - Nếu không tồn tại -> tạo thư mục mới (có thể tạo nhiều cấp)
    
    Sử dụng:
        - Được gọi tự động bởi get_conn() trước khi kết nối
        - Đảm bảo rằng thư mục luôn tồn tại trước khi lưu file database
    
    Ví dụ:
        DB_PATH = "./data/dictionary.db"
        _ensure_db_dir()  # Nếu ./data không tồn tại -> tạo ./data
    """
    db_dir = os.path.dirname(os.path.abspath(DB_PATH))
    if db_dir and not os.path.exists(db_dir):
        os.makedirs(db_dir, exist_ok=True)


# Hàm khởi tạo cơ sở dữ liệu lần đầu tiên
def init_db() -> None:
    """
    Khởi tạo database lần đầu tiên bằng cách tạo tất cả các bảng.
    
    Tác dụng:
        1. Gọi _ensure_db_dir() để tạo thư mục nếu cần
        2. Tìm file schema_sqlite.sql (chứa cấu trúc tất cả các bảng)
        3. Đọc file schema
        4. Thực thi tất cả các câu lệnh CREATE TABLE từ file schema
        5. Commit transaction để lưu các bảng vào database
    
    Cấu trúc bảng từ schema:
        - words: Bảng chính chứa từ vựng
        - word_senses: Các định nghĩa của từ
        - word_examples: Các ví dụ sử dụng
        - synonyms: Các từ đồng nghĩa
        - proverbs: Các tục ngữ/thành ngữ
        - topics: Các chuyên đề/danh mục
        - word_topics: Quan hệ giữa từ và chuyên đề
        - related_words: Các từ liên quan
    
    Sử dụng:
        - Được gọi từ main.py trong startup event
        - Chỉ chạy lần đầu tiên hoặc nếu database chưa tồn tại
        - Nếu database đã tồn tại, các bảng không tạo lại (nếu IF NOT EXISTS)
    
    Chú ý:
        - File schema_sqlite.sql phải tồn tại trong thư mục backend
        - Nếu schema không tồn tại -> sẽ raise FileNotFoundError
    """
    _ensure_db_dir()
    schema_path = os.path.join(os.path.dirname(__file__), "..", "schema_sqlite.sql")
    schema_path = os.path.abspath(schema_path)
    with get_conn() as conn:
        with open(schema_path, "r", encoding="utf-8") as f:
            conn.executescript(f.read())
        conn.commit()


# Hàm kết nối tới database
@contextmanager
def get_conn():
    """
    Context manager để kết nối tới database SQLite.
    
    Cấu hình:
        - Sử dụng @contextmanager decorator để hỗ trợ 'with' statement
        - row_factory = sqlite3.Row: Cho phép truy cập cột bằng tên (row['name']) 
          thay vì index (row[0])
        - PRAGMA foreign_keys = ON: Bật ràng buộc khóa ngoài (cascade delete)
        - Tự động đóng kết nối sau khi thực hiện (finally block)
    
    Sử dụng:
        with get_conn() as conn:
            cur = conn.cursor()
            cur.execute("SELECT * FROM words")
            # Connection tự động đóng khi vòng lặp kết thúc
    
    Benefits:
        - Đơn giản hóa quản lý kết nối (không cần close() bằng tay)
        - Tránh memory leak nếu có lỗi xảy ra (finally block đảm bảo close)
        - Hỗ trợ nested transactions (mặc dù SQLite không thực sự support)
    
    Return:
        sqlite3.Connection: Đối tượng kết nối có thể dùng để thực hiện SQL
    """
    _ensure_db_dir()
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON;")
    try:
        yield conn
    finally:
        conn.close()


# Hàm chuyển đổi kết quả row thành dictionary
def _rows_to_dicts(rows: Iterable[sqlite3.Row]) -> List[Dict[str, Any]]:
    """
    Chuyển đổi các hàng (Row objects) từ database thành danh sách từ điển.
    
    Tham số:
        rows (Iterable[sqlite3.Row]): Các hàng từ kết quả truy vấn
                                       (sqlite3.Row objects khi row_factory = sqlite3.Row)
    
    Trả về:
        List[Dict[str, Any]]: Danh sách các dictionary, mỗi dictionary là một hàng
    
    Tác dụng:
        - Chuyển đổi sqlite3.Row objects thành plain Python dictionaries
        - Cho phép dễ dàng serialize thành JSON (Pydantic models cần dicts)
        - Một Row object sau khi chuyển thành dict có thể unpacking **dict
    
    Ví dụ:
        rows = [sqlite3.Row({'id': 1, 'name': 'abc'}), ...]
        dicts = _rows_to_dicts(rows)
        # dicts = [{'id': 1, 'name': 'abc'}, ...]
        
        # Sau đó dùng để tạo Pydantic model:
        word = WordOut(**dicts[0])
    
    Chú ý:
        - Hàm này là private (bắt đầu với _), không được gọi từ code khác
        - Được dùng bởi query_all() và _rows_to_dicts()
    """
    return [dict(row) for row in rows]


# Hàm lấy nhiều hàng từ database
def query_all(sql: str, params: Optional[Iterable[Any]] = None) -> List[Dict[str, Any]]:
    """
    Truy vấn tất cả các hàng khớp với điều kiện từ database.
    
    Tham số:
        sql (str): Câu lệnh SQL (ví dụ: "SELECT * FROM words WHERE id > ?")
                  - Sử dụng ? để placeholder cho safety (SQL injection protection)
                  - Ví dụ: "SELECT * FROM words WHERE word LIKE ?"
        params (Optional[Iterable[Any]]): Giá trị để thay thế ? trong câu SQL
                                         - Có thể là tuple, list, hoặc None
                                         - Ví dụ: ['%thương%', 10]
                                         - Các giá trị sẽ được escaped tự động
    
    Trả về:
        List[Dict[str, Any]]: Danh sách các dictionary chứa dữ liệu
                             - Nếu không tìm thấy -> return []
                             - Mỗi dictionary có keys là tên cột
                             - Ví dụ: [{'id': 1, 'word': 'thương'}, {'id': 2, 'word': 'yêu'}]
    
    Process:
        1. Gọi get_conn() để kết nối database
        2. Tạo cursor từ connection
        3. Execute SQL với parameters (placeholders được thay thế)
        4. Lấy tất cả kết quả với fetchall()
        5. Chuyển đổi các Row objects thành dicts
        6. Connection tự động đóng (bởi context manager)
    
    Vi dụ:
        # Lấy tất cả từ
        rows = query_all("SELECT * FROM words")
        # rows = [{'id': 1, 'word': 'thương'}, ...]
        
        # Tìm kiếm từ có chứa 'th'
        rows = query_all("SELECT * FROM words WHERE word LIKE ?", ['%th%'])
        
        # Lấy từ với ID cụ thể
        rows = query_all("SELECT * FROM words WHERE id = ?", [1])
        
        # Lấy các từ từ topic 5 (JOIN)
        rows = query_all(
            "SELECT w.* FROM words w JOIN word_topics wt ON w.id = wt.word_id WHERE wt.topic_id = ?",
            [5]
        )
    
    Chú ý:
        - Luôn sử dụng ? placeholders, không bao giờ string concatenation
        - Nếu không có kết quả -> return [], không raise exception
        - Mỗi lần gọi mở và đóng một kết nối mới (không là singleton connection)
        - Đây là read-only operation (không sửa dữ liệu)
    """
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute(sql, params or [])
        rows = cur.fetchall()
        return _rows_to_dicts(rows)


# Hàm lấy một hàng từ database
def query_one(sql: str, params: Optional[Iterable[Any]] = None) -> Optional[Dict[str, Any]]:
    """
    Truy vấn một hàng từ database (hàng đầu tiên nếu có nhiều).
    
    Tham số:
        sql (str): Câu lệnh SQL
                  - Ví dụ: "SELECT * FROM words WHERE id = ?"
                  - Ví dụ: "SELECT COUNT(*) AS c FROM words"
        params (Optional[Iterable[Any]]): Giá trị để thay thế ? trong câu SQL
                                         - Ví dụ: [1], [5000]
    
    Trả về:
        Optional[Dict[str, Any]]: 
        - Nếu tìm thấy -> return dictionary với 1 hàng dữ liệu
        - Nếu không tìm thấy -> return None
        - Ví dụ: {'id': 1, 'word': 'thương', 'pronunciation': 'thương', ...}
        - Ví dụ (COUNT): {'c': 5000}
    
    Process:
        1. Gọi get_conn() để kết nối database
        2. Tạo cursor từ connection
        3. Execute SQL với parameters
        4. Lấy một kết quả với fetchone()
        5. Nếu không có kết quả -> return None
        6. Nếu có kết quả -> chuyển đổi Row thành dict và return
        7. Connection tự động đóng
    
    Ví dụ:
        # Lấy từ với ID cụ thể
        word = query_one("SELECT * FROM words WHERE id = ?", [1])
        # word = {'id': 1, 'word': 'thương', 'pronunciation': '...', ...}
        
        # Kiểm tra từ tồn tại không
        word = query_one("SELECT id FROM words WHERE word = ?", ['thương'])
        if word:
            print(f"Từ tồn tại, ID: {word['id']}")
        else:
            print("Từ không tồn tại")
        
        # Đếm tổng số từ
        result = query_one("SELECT COUNT(*) AS total FROM words")
        # result = {'total': 5000}
        total = result['total']
        
        # Lấy định nghĩa đầu tiên của từ
        sense = query_one(
            "SELECT * FROM word_senses WHERE word_id = ? ORDER BY sense_order LIMIT 1",
            [1]
        )
    
    Chú ý:
        - Luôn kiểm tra if result is not None hay if result trước khi truy cập
        - Nếu muốn lấy tất cả kết quả -> dùng query_all()
        - Đây là read-only operation
        - Mỗi lần gọi mở một kết nối mới
    """
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute(sql, params or [])
        row = cur.fetchone()
        if not row:
            return None
        return dict(row)


# Hàm thực hiện câu lệnh SQL (UPDATE, DELETE, ...)
def execute(sql: str, params: Optional[Iterable[Any]] = None) -> int:
    """
    Thực hiện câu lệnh SQL để sửa hoặc xóa dữ liệu (UPDATE, DELETE, ...).
    
    Tham số:
        sql (str): Câu lệnh SQL
                  - Ví dụ: "UPDATE words SET part_of_speech = ? WHERE id = ?"
                  - Ví dụ: "DELETE FROM synonyms WHERE id = ?"
                  - Ví dụ: "UPDATE word_senses SET definition = ? WHERE id = ?"
        params (Optional[Iterable[Any]]): Giá trị để thay thế ? trong câu SQL
                                         - Ví dụ: ['động từ', 1]
                                         - Ví dụ: [5]
    
    Trả về:
        int: Số hàng bị ảnh hưởng (changed rows)
        - UPDATE: số hàng được update
        - DELETE: số hàng được xóa
        - INSERT: thường 0 hoặc 1 (dùng execute_insert cho INSERT)
    
    Process:
        1. Gọi get_conn() để kết nối database
        2. Tạo cursor từ connection
        3. Execute SQL với parameters
        4. Commit transaction (thay đổi được lưu vào database)
        5. Return cur.rowcount (số hàng bị ảnh hưởng)
        6. Connection tự động đóng
    
    Ví dụ:
        # Cập nhật từ
        affected = execute(
            "UPDATE words SET part_of_speech = ? WHERE id = ?",
            ['động từ', 1]
        )
        print(f"Cập nhật {affected} từ")  # Cập nhật 1 từ (hoặc 0 nếu ID không tồn tại)
        
        # Xóa một ví dụ
        affected = execute("DELETE FROM word_examples WHERE id = ?", [10])
        if affected == 0:
            print("Ví dụ không tồn tại")
        else:
            print("Xóa ví dụ thành công")
        
        # Xóa tất cả ví dụ của một từ
        affected = execute("DELETE FROM word_examples WHERE word_id = ?", [1])
        print(f"Xóa {affected} ví dụ")
    
    Chú ý:
        - Luôn check rowcount để xác nhận thao tác thành công
        - Nếu rowcount == 0 -> không tìm thấy record để cập nhật/xóa
        - Không dùng cho INSERT (có lastrowid) -> dùng execute_insert()
        - Mỗi lần gọi commit() -> mở/đóng transaction mới
        - PRAGMA foreign_keys được bật -> DELETE có thể cascade
    """
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute(sql, params or [])
        conn.commit()
        return cur.rowcount


# Hàm thực hiện câu lệnh INSERT (thêm đữ liệu mới)
def execute_insert(sql: str, params: Optional[Iterable[Any]] = None) -> int:
    """
    Thêm dữ liệu mới vào database với INSERT statement.
    
    Tham số:
        sql (str): Câu lệnh INSERT
                  - Ví dụ: "INSERT INTO words (word, pronunciation) VALUES (?, ?)"
                  - Ví dụ: "INSERT INTO word_senses (word_id, sense_order, definition) VALUES (?, ?, ?)"
        params (Optional[Iterable[Any]]): Giá trị để thay thế ? trong câu SQL
                                         - Ví dụ: ['thương', 'thương']
                                         - Ví dụ: [1, 1, 'to love, to pity']
    
    Trả về:
        int: ID của bản ghi vừa INSERT (lastrowid)
        - Có thể dùng để tham chiếu bản ghi mới hoặc tạo quan hệ
        - SQLite tự động tăng ID cho primary key
    
    Process:
        1. Gọi get_conn() để kết nối database
        2. Tạo cursor từ connection
        3. Execute INSERT SQL với parameters
        4. Commit transaction
        5. Return cur.lastrowid (ID của dòng vừa INSERT)
        6. Connection tự động đóng
    
    Ví dụ:
        # Tạo từ mới
        word_id = execute_insert(
            "INSERT INTO words (word, pronunciation) VALUES (?, ?)",
            ['thương', 'thương']
        )
        print(f"Từ mới có ID: {word_id}")  # word_id = 5001
        
        # Tạo định nghĩa cho từ mới
        sense_id = execute_insert(
            "INSERT INTO word_senses (word_id, sense_order, definition) VALUES (?, ?, ?)",
            [word_id, 1, "to love, to pity"]
        )
        print(f"Định nghĩa mới có ID: {sense_id}")
        
        # Tạo ví dụ cho từ
        example_id = execute_insert(
            "INSERT INTO word_examples (word_id, example_text) VALUES (?, ?)",
            [word_id, "Tôi thương anh ấy"]
        )
        
        # Tạo từ đồng nghĩa
        synonym_id = execute_insert(
            "INSERT INTO synonyms (word_id, synonym_word_id, intensity) VALUES (?, ?, ?)",
            [word_id, 2, 8]
        )
    
    Chú ý:
        - Luôn lưu lastrowid để tham chiếu record mới
        - Nếu INSERT thất bại -> sẽ raise exception (db constraint violation)
        - SQLite auto-increment ID từ 1, 2, 3, ...
        - Trong FastAPI, dùng lastrowid để return ID mới cho client
        - Không check rowcount (INSERT luôn thành công hoặc lỗi)
    """
    with get_conn() as conn:
        cur = conn.cursor()
        cur.execute(sql, params or [])
        conn.commit()
        return int(cur.lastrowid)
