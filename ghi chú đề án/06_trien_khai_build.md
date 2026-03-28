# 06 - Trien khai va build

## Buoc 1: Cap nhat config API
- dictionary_app\lib\config.dart
- dictionary_admin_app\lib\config.dart

## Buoc 2: Build Windows
- flutter build windows --release
- File exe trong thu muc Release

## Buoc 3: Build Android
- Can Android SDK
- flutter build appbundle
- File AAB trong build\app\outputs\bundle\release

## Buoc 4: Kiem tra backend
- Mo https://dictionary-q5mo.onrender.com/health
- Neu status ok thi backend san sang

## Buoc 5: Gui app cho nguoi dung
- Zip thu muc Release cua app nguoi dung
- Gui cho nguoi dung giai nen va chay dictionary_app.exe
