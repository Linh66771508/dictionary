// ============================================================================
// FILE: admin_shell.dart - KHUNG CHÍNH CỦA ỨNG DỤNG QUẢN TRỊ
// TÁC DỤG: Đền dẫn người dùng giữa các phạm vụ quản lý khác nhau
// GIAO DIỆN:
//   - Bên trái: Sidebar (NavigationRail) với các tab:
//     ~~ Tổng quan (Dashboard)
//     ~~ Quản lý từ vựng
//     ~~ Quản lý đồng nghĩa
//     ~~ Quản lý thành ngữ
//     ~~ Quản lý chủ đề
//   - Bên phải: Nội dung của tab hiện tại
// ============================================================================

import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'dictionary_management_screen.dart';
import 'synonym_management_screen.dart';
import 'proverb_management_screen.dart';
import 'topic_management_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  /// Biến tracking tab/trang hiện tại
  /// - index = 0: Dashboard (Tổng quan)
  /// - index = 1: Dictionary Management (Quản lý từ vựng)
  /// - index = 2: Synonym Management (Quản lý từ đồng nghĩa)
  /// - index = 3: Proverb Management (Quản lý tục ngữ)
  /// - index = 4: Topic Management (Quản lý chủ đề)
  int index = 0;

  /// Danh sách 5 trang/màn hình quản lý
  /// Thứ tự phải khớp với index trên
  /// - [0] DashboardScreen: Hiển thị thống kê (tổng từ, thành ngữ, ...)
  /// - [1] DictionaryManagementScreen: Thêm/sửa/xóa từ vựng
  /// - [2] SynonymManagementScreen: Quản lý quan hệ từ đồng nghĩa
  /// - [3] ProverbManagementScreen: Quản lý thành ngữ/tục ngữ
  /// - [4] TopicManagementScreen: Quản lý chủ đề/danh mục
  final List<Widget> pages = const [
    DashboardScreen(),
    DictionaryManagementScreen(),
    SynonymManagementScreen(),
    ProverbManagementScreen(),
    TopicManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    /// Build giao diện chính của admin app
    /// Layout:
    ///   Scaffold
    ///   └─ Row
    ///      ├─ NavigationRail (bên trái)
    ///      │  └─ 5 navigation destinations
    ///      ├─ VerticalDivider (phân cách)
    ///      └─ Expanded (nội dung bên phải)
    ///         └─ pages[index] (trang hiện tại)
    return Scaffold(
      body: Row(
        children: [
          /// NavigationRail: Thanh điều hướng bên trái
          /// - selectedIndex: tracking tab nào đang active
          /// - onDestinationSelected: callback khi user click tab
          /// - labelType: hiển thị label + icon (all)
          NavigationRail(
            selectedIndex: index,
            onDestinationSelected: (value) {
              /// Khi user click một tab:
              /// 1. Gọi setState() để rebuild widget
              /// 2. Cập nhật biến index = value (tab mới)
              /// 3. build() tự động gọi lại -> hiển thị pages[index] mới
              /// 4. Giao diện được update (tab active, nội dung thay đổi)
              setState(() => index = value);
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Tổng quan'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: Text('Từ vựng'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.compare_arrows_outlined),
                selectedIcon: Icon(Icons.compare_arrows),
                label: Text('Đồng nghĩa'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.article_outlined),
                selectedIcon: Icon(Icons.article),
                label: Text('Tục ngữ'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.category_outlined),
                selectedIcon: Icon(Icons.category),
                label: Text('Chủ đề'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),

          /// Expanded: Chiếm phần còn lại của màn hình
          /// - Hiển thị pages[index] (trang hiện tại)
          /// - Khi index thay đổi -> widget được rebuild -> trang mới hiển thị
          /// - Mỗi trang có logic riêng (state, API calls, ...)
          Expanded(child: pages[index]),
        ],
      ),
    );
  }
}
