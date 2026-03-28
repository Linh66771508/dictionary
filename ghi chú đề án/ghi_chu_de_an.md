# Ghi chú đề án (Từ điển Tiếng Việt)

## 1) Mục tiêu hệ thống
- Xây dựng app từ điển tiếng Việt – Việt có tra cứu từ, từ đồng nghĩa, thành ngữ/tục ngữ, tra theo chủ đề.
- Có 2 app:
  - App người dùng (tra cứu)
  - App admin (quản lý dữ liệu)
- Backend API phục vụ cả 2 app.

## 2) Kiến trúc tổng quát
- Frontend: Flutter desktop (Windows) và Android (Google Play).
- Backend: FastAPI (Python) chạy online.
- Database: SQLite (đơn giản, miễn phí, phù hợp Render Free).

Luồng chính:
- App người dùng gọi API đọc dữ liệu.
- App admin gọi API để thêm/xóa từ, đồng nghĩa, tục ngữ.
- Backend đọc/ghi dữ liệu trong SQLite.

## 3) Các thư mục chính
- D:\study\dictionary\dictionary_app: app người dùng
- D:\study\dictionary\dictionary_admin_app: app admin
- D:\study\dictionary\backend: backend FastAPI + SQLite
- D:\study\dictionary\render.yaml: cấu hình deploy Render

## 4) Các công cụ đã dùng
- Flutter: tạo app desktop + Android
- FastAPI: xây dựng API backend
- SQLite: lưu dữ liệu từ điển
- Render: deploy backend miễn phí
- Git + GitHub: quản lý mã nguồn và deploy Render
- PowerShell: chạy lệnh build / deploy

## 5) Các thay đổi quan trọng đã thực hiện
- Chuyển backend từ SQL Server sang SQLite để chạy free trên Render.
- Tạo file schema SQLite: backend\schema_sqlite.sql.
- Cập nhật db.py để dùng sqlite3 và tự tạo DB khi chạy.
- Cập nhật API SQL (TOP/OUTER APPLY/OUTPUT) sang cú pháp SQLite (LIMIT/LEFT JOIN/lastrowid).
- Cập nhật URL backend trong app:
  - dictionary_app\lib\config.dart
  - dictionary_admin_app\lib\config.dart

## 6) Backend FastAPI (SQLite)
- Cấu hình .env:
  - SQLITE_DB_PATH=./data/dictionary.db
- Khi chạy lần đầu sẽ tự tạo DB và bảng.
- File DB nằm tại: backend\data\dictionary.db

Chạy local:
- cd D:\study\dictionary\backend
- python -m pip install -r requirements.txt
- python -m uvicorn app.main:app --host 127.0.0.1 --port 8000

## 7) Deploy backend lên Render (free)
- Đẩy code lên GitHub.
- Render đọc render.yaml (rootDir=backend).
- Start command:
  - python -m uvicorn app.main:app --host 0.0.0.0 --port $PORT
- URL Render hiện tại:
  - https://dictionary-q5mo.onrender.com

Lưu ý:
- Render Free có thể “ngủ” khi không truy cập, lần mở đầu có thể chậm.

## 8) App Flutter (Windows)
Build release:
- cd D:\study\dictionary\dictionary_app
- flutter build windows --release

File exe:
- D:\study\dictionary\dictionary_app\build\windows\x64\runner\Release\dictionary_app.exe

## 9) App Admin (Windows)
Build release:
- cd D:\study\dictionary\dictionary_admin_app
- flutter build windows --release

File exe:
- D:\study\dictionary\dictionary_admin_app\build\windows\x64\runner\Release\dictionary_admin_app.exe

## 10) App Android (Google Play)
- Cần cài Android SDK.
- Build AAB:
  - flutter build appbundle
- File AAB:
  - dictionary_app\build\app\outputs\bundle\release\app-release.aab

## 11) Các chức năng admin đã có
- Thêm / xóa từ
- Thêm / xóa đồng nghĩa
- Thêm / xóa tục ngữ

## 12) Các vấn đề kỹ thuật đã gặp và cách xử lý
- Lỗi Unicode path: di chuyển dự án sang D:\study\dictionary.
- Lỗi symlink plugin: xóa .dart_tool, build, windows\flutter\ephemeral rồi build lại.
- Backend không chạy: phải chạy uvicorn trước khi mở app.
- Render deploy fail do rootDir: cần set rootDir=backend hoặc dùng render.yaml.

## 13) Phương thức triển khai
- Backend online: Render Free.
- Database: SQLite file.
- App Windows: build exe release.
- App Android: build AAB để phát hành Play Store.

## 14) Ghi chú phát hành
- App người dùng: phát hành lên Google Play.
- App admin: dùng nội bộ, không phát hành store.
- Cần tạo icon chuẩn và ký app trước khi upload.
