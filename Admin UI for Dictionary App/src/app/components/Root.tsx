import { Outlet, Link, useLocation } from "react-router";
import { Book, BookMarked, FileText, Home } from "lucide-react";
import { cn } from "./ui/utils";

export default function Root() {
  const location = useLocation();

  const navItems = [
    { path: "/", label: "Tổng quan", icon: Home },
    { path: "/dictionary", label: "Quản lý từ vựng", icon: Book },
    { path: "/synonyms", label: "Quản lý đồng nghĩa", icon: BookMarked },
    { path: "/proverbs", label: "Quản lý tục ngữ", icon: FileText },
  ];

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <aside className="w-64 bg-white border-r border-gray-200">
        <div className="p-6">
          <h1 className="font-bold text-xl text-gray-900">
            Từ điển Tiếng Việt
          </h1>
          <p className="text-sm text-gray-500 mt-1">Admin Dashboard</p>
        </div>
        <nav className="px-3 space-y-1">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive =
              item.path === "/"
                ? location.pathname === "/"
                : location.pathname.startsWith(item.path);

            return (
              <Link
                key={item.path}
                to={item.path}
                className={cn(
                  "flex items-center gap-3 px-3 py-2 rounded-lg transition-colors",
                  isActive
                    ? "bg-blue-50 text-blue-700"
                    : "text-gray-700 hover:bg-gray-100"
                )}
              >
                <Icon className="w-5 h-5" />
                <span className="text-sm font-medium">{item.label}</span>
              </Link>
            );
          })}
        </nav>
      </aside>

      {/* Main Content */}
      <main className="flex-1 overflow-auto">
        <Outlet />
      </main>
    </div>
  );
}
