# 10 - Giai thich code app admin (Flutter)

Tai lieu nay giai thich tung file, tung chuc nang trong app admin.

## Tong quan luong hoat dong
- Admin mo app -> xem dashboard
- Chon tu trong danh sach -> sua thong tin, nghia, vi du
- Quan ly dong nghia va tuc ngu o man hinh rieng
- Quan ly chu de: them/xoa chu de, them/xoa tu trong chu de

## Cac file chinh va vai tro

### 1) lib/main.dart
- Entry point, khoi tao theme va AdminShell.

### 2) lib/config.dart
- Luu URL backend.
- Khi doi server, cap nhat tai day.

### 3) lib/services/api_client.dart
- Goi API admin (CRUD tu, nghia, vi du, dong nghia, tuc ngu).
- Them API chu de: listTopics, createTopic, deleteTopic, addWordToTopic, removeWordFromTopic.

### 4) lib/models/*
- Du lieu cho admin:
  - word_summary.dart
  - word_detail.dart
  - meaning.dart
  - example.dart
  - synonym.dart
  - proverb.dart
  - admin_stats.dart
  - topic.dart

### 5) lib/screens/admin_shell.dart
- Layout chinh, chua NavigationRail.
- Chuyen tab (Dashboard, Tu vung, Dong nghia, Tuc ngu, Chu de).

### 6) lib/screens/dashboard_screen.dart
- Hien thong ke tong quan.

### 7) lib/screens/dictionary_management_screen.dart
- Quan ly tu vung.
- Sua thong tin tu.
- Them/sua/xoa nghia.
- Them/sua/xoa vi du.

### 8) lib/screens/synonym_management_screen.dart
- Quan ly dong nghia rieng.
- Them/sua/xoa dong nghia.

### 9) lib/screens/proverb_management_screen.dart
- Quan ly tuc ngu rieng.
- Them/sua/xoa tuc ngu.

### 10) lib/screens/topic_management_screen.dart
- Quan ly chu de.
- Them/xoa chu de.
- Tim tu va them vao chu de.
- Xoa tu khoi chu de.

## File co the chinh sua (lap trinh vien can tac dong)
- lib/main.dart
- lib/config.dart
- lib/services/api_client.dart
- lib/models/*
- lib/screens/*

## File thuong khong can sua
- android/, ios/, windows/, macos/, linux/
- pubspec.lock, .metadata, .dart_tool
