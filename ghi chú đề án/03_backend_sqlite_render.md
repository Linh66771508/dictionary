# 03 - Backend SQLite va Render

## Cau hinh SQLite
- File DB mac dinh: backend\data\dictionary.db
- Bien moi truong: SQLITE_DB_PATH=./data/dictionary.db
- Schema: backend\schema_sqlite.sql

## Cac bang du lieu
- words
- word_senses
- word_examples
- topics
- word_topics
- synonyms
- proverbs
- related_words

## Chuyen doi tu SQL Server sang SQLite
- Thay TOP va OUTER APPLY bang LEFT JOIN + subquery MIN(sense_order).
- Thay OUTPUT INSERTED.id bang lastrowid.
- Thay OFFSET FETCH bang LIMIT OFFSET.

## Chay local
- cd D:\study\dictionary\backend
- python -m pip install -r requirements.txt
- python -m uvicorn app.main:app --host 127.0.0.1 --port 8000

## Deploy Render
- Repo GitHub co file render.yaml o root.
- render.yaml su dung rootDir: backend.
- Build command: pip install -r requirements.txt
- Start command: python -m uvicorn app.main:app --host 0.0.0.0 --port $PORT
- URL Render: https://dictionary-q5mo.onrender.com

## Luu y Render Free
- Sleep sau mot thoi gian khong truy cap.
- Lan goi dau co the cham 30-60 giay.
