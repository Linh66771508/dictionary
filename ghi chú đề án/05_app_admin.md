# 05 - App admin (Flutter)

## Muc tieu
- Quan ly tu vung.
- Them, xoa, sua tu.
- Them, xoa, sua nghia va vi du.
- Them, xoa, sua dong nghia.
- Them, xoa, sua tuc ngu.

## File chinh
- dictionary_admin_app\lib\main.dart
- dictionary_admin_app\lib\screens\admin_shell.dart
- dictionary_admin_app\lib\screens\dictionary_management_screen.dart
- dictionary_admin_app\lib\screens\synonym_management_screen.dart
- dictionary_admin_app\lib\screens\proverb_management_screen.dart
- dictionary_admin_app\lib\services\api_client.dart
- dictionary_admin_app\lib\config.dart

## API goi su dung
- GET /admin/stats
- GET /admin/words
- POST /admin/words
- PUT /admin/words/{word_id}
- DELETE /admin/words/{word_id}
- POST /admin/words/{word_id}/meanings
- PUT /admin/meanings/{meaning_id}
- DELETE /admin/meanings/{meaning_id}
- POST /admin/words/{word_id}/examples
- PUT /admin/examples/{example_id}
- DELETE /admin/examples/{example_id}
- GET /admin/synonyms
- POST /admin/synonyms
- PUT /admin/synonyms/{synonym_id}
- DELETE /admin/synonyms/{synonym_id}
- GET /admin/proverbs
- POST /admin/proverbs
- PUT /admin/proverbs/{proverb_id}
- DELETE /admin/proverbs/{proverb_id}

## URL backend
- https://dictionary-q5mo.onrender.com

## Build Windows Release
- flutter build windows --release
- File exe: dictionary_admin_app\build\windows\x64\runner\Release\dictionary_admin_app.exe

## Ghi chu
- App admin chi dung noi bo, khong phat hanh store.
