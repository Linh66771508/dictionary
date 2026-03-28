# 09 - Giai thich code app nguoi dung (Flutter)

Tai lieu nay giai thich tung file, tung chuc nang trong app nguoi dung, theo cach de nguoi moi doc hieu.

## Tong quan luong hoat dong
- App mo man hinh Home.
- Nguoi dung tim tu -> goi API -> hien chi tiet tu.
- Nguoi dung bam chu de -> hien danh sach tu trong chu de.

## Cac file chinh va vai tro

### 1) lib/main.dart
- Vai tro: diem vao (entry point) cua app.
- Viec no lam: khoi tao MaterialApp, set theme, goi HomeScreen.
- Khi can sua:
  - Doi ten app (title)
  - Doi theme tong the (mau chu dao, font)

### 2) lib/config.dart
- Vai tro: luu cau hinh toan cuc.
- Viec no lam: chua URL backend API.
- Khi can sua:
  - Doi apiBaseUrl khi backend thay doi (Render URL, server moi).

### 3) lib/services/api_client.dart
- Vai tro: noi goi API.
- Viec no lam:
  - fetchTopics(): lay danh sach chu de
  - searchWords(query): tim tu theo tu khoa
  - getWordById(id): lay chi tiet 1 tu
  - getTopicWords(topicId): lay tu theo chu de
- Khi can sua:
  - Them API moi hoac doi dinh dang du lieu

### 4) lib/models/*
- Vai tro: mo hinh du lieu nhan tu API.
- Vi du:
  - word_summary.dart: tu ngan gon de hien danh sach
  - word_detail.dart: chi tiet tu, nghia, dong nghia, tuc ngu
  - topic.dart: chu de
- Khi can sua:
  - Neu backend doi response thi cap nhat field

### 5) lib/screens/home_screen.dart
- Vai tro: man hinh chinh.
- Viec no lam:
  - Hien header
  - O tim kiem
  - Danh sach tim gan day
  - Danh sach chu de
- Ket noi voi API qua ApiClient.
- Khi can sua:
  - Doi layout, them thanh phan moi
  - Thay logic tim kiem

### 6) lib/screens/word_detail_screen.dart
- Vai tro: man hinh chi tiet tu.
- Viec no lam:
  - Hien tu, loai tu, phat am
  - Hien danh sach nghia
  - Hien vi du
  - Hien dong nghia, tuc ngu, tu lien quan
- Khi can sua:
  - Doi cach sap xep chi tiet
  - Them truong moi tu backend

### 7) lib/screens/topic_screen.dart
- Vai tro: man hinh danh sach tu theo chu de.
- Viec no lam:
  - Goi API lay tu theo chu de
  - Hien list tu
- Khi can sua:
  - Doi layout list

### 8) lib/widgets/search_bar.dart
- Vai tro: thanh tim kiem.
- Viec no lam:
  - Nhap tu khoa va bam nut Tra
- Khi can sua:
  - Doi giao dien thanh tim kiem

### 9) lib/widgets/topic_card.dart
- Vai tro: the hien tung chu de.
- Viec no lam:
  - Hien icon, ten chu de, mo ta, so luong tu
- Khi can sua:
  - Doi cach hien thi chu de

## File co the chinh sua (lap trinh vien can tac dong)
- lib/main.dart
- lib/config.dart
- lib/services/api_client.dart
- lib/models/*
- lib/screens/*
- lib/widgets/*

## File thuong khong can sua
- android/, ios/, windows/, macos/, linux/: thu muc platform (chi sua khi can doi icon, package, signing)
- pubspec.lock: tu dong sinh
- .metadata, .dart_tool: tu dong sinh
