# 11 - Giai thich code backend (FastAPI + SQLite)

Tai lieu nay giai thich tung file, tung chuc nang backend.

## Tong quan
- Backend cung cap API cho app nguoi dung va admin.
- Tu dong tao database SQLite khi khoi dong.

## Cac file chinh va vai tro

### 1) backend/app/main.py
- Dinh nghia API FastAPI.
- Cac route chinh:
  - /health
  - /topics, /topics/{id}/words
  - /words/search, /words/id/{id}, /words/by-text/{text}
  - /admin/words (GET/POST/PUT/DELETE)
  - /admin/words/{id}/meanings (POST)
  - /admin/meanings/{id} (PUT/DELETE)
  - /admin/words/{id}/examples (POST)
  - /admin/examples/{id} (PUT/DELETE)
  - /admin/synonyms (GET/POST/PUT/DELETE)
  - /admin/proverbs (GET/POST/PUT/DELETE)

### 2) backend/app/db.py
- Quan ly ket noi SQLite.
- Ham init_db() tao bang theo schema_sqlite.sql.
- Ham query_all, query_one, execute de thao tac DB.

### 3) backend/schema_sqlite.sql
- Chua schema DB.
- Bao gom bang words, word_senses, word_examples, topics, word_topics, synonyms, proverbs, related_words.

### 4) backend/requirements.txt
- Danh sach thu vien:
  - fastapi
  - uvicorn
  - python-dotenv

### 5) backend/.env
- Cau hinh bien moi truong.
- SQLITE_DB_PATH.

## File co the chinh sua (lap trinh vien can tac dong)
- backend/app/main.py
- backend/app/db.py
- backend/schema_sqlite.sql
- backend/.env

## File thuong khong can sua
- backend/data/dictionary.db (file du lieu)
- __pycache__ (tu dong sinh)
