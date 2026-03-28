# 12 - Phan loai file co the tac dong va file tinh

## A) File lap trinh vien thuong xuyen chinh sua

### App nguoi dung
- dictionary_app\lib\main.dart (cau hinh app, theme)
- dictionary_app\lib\config.dart (URL backend)
- dictionary_app\lib\services\api_client.dart (goi API)
- dictionary_app\lib\models\* (dinh nghia du lieu)
- dictionary_app\lib\screens\* (giao dien)
- dictionary_app\lib\widgets\* (thanh phan UI)

### App admin
- dictionary_admin_app\lib\main.dart
- dictionary_admin_app\lib\config.dart
- dictionary_admin_app\lib\services\api_client.dart
- dictionary_admin_app\lib\models\*
- dictionary_admin_app\lib\screens\*

### Backend
- backend\app\main.py (API routes)
- backend\app\db.py (DB sqlite)
- backend\schema_sqlite.sql (schema)
- backend\.env (cau hinh)
- render.yaml (cau hinh deploy Render)

## B) File it can sua / chi chinh khi can

### Flutter platform files
- android/, ios/, windows/, macos/, linux/
  - Chi sua khi doi icon, package id, signing, build config.

### Build va cache
- .dart_tool, build/, .metadata, pubspec.lock
  - Tu dong sinh, khong sua thu cong.

### Database
- backend\data\dictionary.db
  - File du lieu. Nen sua thong qua admin app, khong sua thu cong.

## C) File tinh hoac tai lieu
- README.md
- ATTRIBUTIONS.md
- Guidelines.md
- Tai lieu do an, cac file .docx, .pdf

## Ghi chu
- Neu doi URL backend, chi sua trong config.dart cua 2 app.
- Neu doi schema, phai cap nhat schema_sqlite.sql va logic trong main.py.
