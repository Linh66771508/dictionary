import { SearchBar } from "./search-bar";
import { TopicExploration } from "./topic-exploration";
import { BookOpen, Clock, Sparkles } from "lucide-react";

interface HomeScreenProps {
  searchValue: string;
  onSearchChange: (value: string) => void;
  onSearchSubmit: () => void;
  topics: Array<{ id: string; name: string; wordCount: number; icon: string }>;
  onTopicClick: (topicId: string) => void;
  recentWords?: string[];
  onRecentWordClick: (word: string) => void;
}

export function HomeScreen({ 
  searchValue, 
  onSearchChange, 
  onSearchSubmit,
  topics,
  onTopicClick,
  recentWords = [],
  onRecentWordClick
}: HomeScreenProps) {
  return (
    <div className="min-h-screen bg-gradient-to-b from-blue-50 via-purple-50 to-pink-50">
      {/* Header Card - Flutter Container/Card */}
      <div className="bg-gradient-to-r from-blue-600 to-purple-600 text-white shadow-lg">
        <div className="px-4 pt-6 pb-5">
          <div className="flex items-center gap-2 mb-2">
            <div className="p-2 bg-white/20 rounded-lg">
              <BookOpen className="size-6 text-white" />
            </div>
            <h1 className="text-2xl font-bold">Từ điển Tiếng Việt</h1>
            <Sparkles className="size-5 text-yellow-300" />
          </div>
          <p className="text-sm text-white/90">Tra cứu từ vựng nhanh chóng và dễ dàng</p>
        </div>
      </div>

      {/* Column layout - Flutter Column */}
      <div className="p-4 space-y-4">
        
        {/* Search Card */}
        <div>
          <SearchBar 
            value={searchValue}
            onChange={onSearchChange}
            onSearch={onSearchSubmit}
            placeholder="Nhập từ cần tra..."
          />
        </div>

        {/* Recent Words Card */}
        {recentWords.length > 0 && (
          <div className="bg-white rounded-xl border-2 border-indigo-200 p-4 shadow-md">
            <div className="flex items-center gap-2 mb-3">
              <div className="p-2 bg-indigo-100 rounded-lg">
                <Clock className="size-4 text-indigo-600" />
              </div>
              <h3 className="font-bold text-gray-900 text-sm">Tìm kiếm gần đây</h3>
            </div>
            
            {/* Horizontal scrollable row */}
            <div className="flex gap-2 overflow-x-auto pb-1">
              {recentWords.map((word, index) => (
                <button
                  key={index}
                  onClick={() => onRecentWordClick(word)}
                  className="px-4 py-2 bg-gradient-to-r from-indigo-500 to-purple-500 text-white rounded-full text-sm font-medium border-2 border-indigo-300 whitespace-nowrap hover:shadow-lg hover:scale-105 transition-all shadow-sm"
                >
                  {word}
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Topics Section */}
        <div className="bg-white rounded-xl border-2 border-purple-200 p-4 shadow-md">
          <div className="flex items-center gap-2 mb-4">
            <div className="p-2 bg-purple-100 rounded-lg">
              <Sparkles className="size-4 text-purple-600" />
            </div>
            <h3 className="font-bold text-gray-900">Chủ đề</h3>
          </div>
          <TopicExploration topics={topics} onTopicClick={onTopicClick} />
        </div>
      </div>
    </div>
  );
}
