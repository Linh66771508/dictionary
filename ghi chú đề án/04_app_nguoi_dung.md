# 04 - App nguoi dung (Flutter)

## Muc tieu
- Giao dien tra cuu tu vung.
- Xem chi tiet tu, dong nghia, thanh ngu, chu de.
- Tim kiem nhanh + goi y tu (recommendation) khi go.
- Giao dien responsive: desktop full man, mobile vua khung.

## File chinh
- dictionary_app\lib\main.dart
- dictionary_app\lib\screens\home_screen.dart
- dictionary_app\lib\screens\word_detail_screen.dart
- dictionary_app\lib\screens\topic_screen.dart
- dictionary_app\lib\services\api_client.dart
- dictionary_app\lib\config.dart
- dictionary_app\lib\widgets\search_bar.dart

## API goi su dung
- GET /health
- GET /topics
- GET /topics/{topic_id}/words
- GET /words/search?q= (khong ep kieu, tim gan dung)
- GET /words/search?q=&limit=8 (goi y tu khi go)
- GET /words/id/{word_id}

## URL backend
- https://dictionary-q5mo.onrender.com

## Build Windows Release
- flutter build windows --release
- File exe: dictionary_app\build\windows\x64\runner\Release\dictionary_app.exe

## Build Android AAB
- flutter build appbundle
- File AAB: dictionary_app\build\app\outputs\bundle\release\app-release.aab
