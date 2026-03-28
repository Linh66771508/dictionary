import { Book, BookMarked, FileText, TrendingUp } from "lucide-react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "./ui/card";

export default function Dashboard() {
  const stats = [
    {
      title: "Tổng số từ",
      value: "12,547",
      change: "+234 từ mới",
      icon: Book,
      color: "text-blue-600",
      bg: "bg-blue-100",
    },
    {
      title: "Quan hệ đồng nghĩa",
      value: "3,842",
      change: "+56 mối quan hệ",
      icon: BookMarked,
      color: "text-green-600",
      bg: "bg-green-100",
    },
    {
      title: "Tục ngữ",
      value: "1,234",
      change: "+12 tục ngữ mới",
      icon: FileText,
      color: "text-purple-600",
      bg: "bg-purple-100",
    },
    {
      title: "Hoạt động hôm nay",
      value: "89",
      change: "Chỉnh sửa",
      icon: TrendingUp,
      color: "text-orange-600",
      bg: "bg-orange-100",
    },
  ];

  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Tổng quan</h1>
        <p className="text-gray-500 mt-2">
          Xin chào! Đây là bảng điều khiển quản lý từ điển Tiếng Việt.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat) => {
          const Icon = stat.icon;
          return (
            <Card key={stat.title}>
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <CardTitle className="text-sm font-medium text-gray-700">
                  {stat.title}
                </CardTitle>
                <div className={`p-2 rounded-lg ${stat.bg}`}>
                  <Icon className={`w-4 h-4 ${stat.color}`} />
                </div>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-gray-900">
                  {stat.value}
                </div>
                <p className="text-xs text-gray-500 mt-1">{stat.change}</p>
              </CardContent>
            </Card>
          );
        })}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-8">
        <Card>
          <CardHeader>
            <CardTitle>Hoạt động gần đây</CardTitle>
            <CardDescription>
              Các thay đổi mới nhất trong hệ thống
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {[
                {
                  action: "Thêm từ mới",
                  word: "trí tuệ nhân tạo",
                  time: "2 phút trước",
                },
                {
                  action: "Cập nhật nghĩa",
                  word: "công nghệ",
                  time: "15 phút trước",
                },
                {
                  action: "Thêm đồng nghĩa",
                  word: "xinh đẹp → đẹp đẽ",
                  time: "1 giờ trước",
                },
                {
                  action: "Thêm tục ngữ",
                  word: "Có công mài sắt có ngày nên kim",
                  time: "2 giờ trước",
                },
              ].map((activity, index) => (
                <div key={index} className="flex items-start gap-3">
                  <div className="w-2 h-2 rounded-full bg-blue-500 mt-2"></div>
                  <div className="flex-1">
                    <p className="text-sm font-medium text-gray-900">
                      {activity.action}
                    </p>
                    <p className="text-sm text-gray-600">{activity.word}</p>
                    <p className="text-xs text-gray-400 mt-1">
                      {activity.time}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Từ phổ biến nhất</CardTitle>
            <CardDescription>Được tìm kiếm nhiều nhất tuần này</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {[
                { word: "yêu", count: "1,234 lượt" },
                { word: "hạnh phúc", count: "987 lượt" },
                { word: "tự do", count: "856 lượt" },
                { word: "thành công", count: "743 lượt" },
                { word: "gia đình", count: "698 lượt" },
              ].map((item, index) => (
                <div
                  key={index}
                  className="flex items-center justify-between py-2"
                >
                  <div className="flex items-center gap-3">
                    <span className="flex items-center justify-center w-6 h-6 rounded-full bg-gray-100 text-xs font-medium text-gray-700">
                      {index + 1}
                    </span>
                    <span className="text-sm font-medium text-gray-900">
                      {item.word}
                    </span>
                  </div>
                  <span className="text-xs text-gray-500">{item.count}</span>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
