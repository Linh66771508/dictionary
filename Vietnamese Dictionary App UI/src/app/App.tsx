import { useState } from "react";
import { HomeScreen } from "./components/home-screen";
import { WordDetail } from "./components/word-detail";
import { TopicWords } from "./components/topic-words";

// Mock data for Vietnamese dictionary - Academic style
const mockTopics = [
  { 
    id: "emotions", 
    name: "Cảm xúc & Tâm trạng", 
    wordCount: 148, 
    icon: "😊",
    description: "Từ vựng mô tả cảm xúc, tâm trạng"
  },
  { 
    id: "transportation", 
    name: "Giao thông & Vận tải", 
    wordCount: 92, 
    icon: "🚗",
    description: "Phương tiện và hệ thống giao thông"
  },
  { 
    id: "food", 
    name: "Ẩm thực & Văn hóa", 
    wordCount: 176, 
    icon: "🍜",
    description: "Thực phẩm, món ăn và văn hóa ẩm thực"
  },
  { 
    id: "nature", 
    name: "Thiên nhiên & Môi trường", 
    wordCount: 134, 
    icon: "🌿",
    description: "Hiện tượng tự nhiên và sinh thái"
  },
  { 
    id: "work", 
    name: "Công việc & Nghề nghiệp", 
    wordCount: 118, 
    icon: "💼",
    description: "Hoạt động lao động và chuyên môn"
  },
  { 
    id: "family", 
    name: "Gia đình & Quan hệ", 
    wordCount: 87, 
    icon: "👨‍👩‍👧",
    description: "Mối quan hệ gia đình và xã hội"
  },
];

const mockTopicWords: Record<string, Array<{ word: string; shortDef: string; partOfSpeech: string; frequency?: string }>> = {
  emotions: [
    { word: "Vui vẻ", shortDef: "Có tâm trạng vui, sung sướng, phấn khởi", partOfSpeech: "Tính từ", frequency: "Cao" },
    { word: "Buồn bã", shortDef: "Tâm trạng u buồn, không vui", partOfSpeech: "Tính từ", frequency: "Cao" },
    { word: "Phấn khích", shortDef: "Trạng thái hưng phấn, kích động mạnh", partOfSpeech: "Tính từ", frequency: "TB" },
    { word: "Lo lắng", shortDef: "Cảm giác bất an, băn khoăn", partOfSpeech: "Tính từ", frequency: "Cao" },
    { word: "Hạnh phúc", shortDef: "Trạng thái cảm xúc tích cực, sung sướng", partOfSpeech: "Tính từ", frequency: "Cao" },
    { word: "Thất vọng", shortDef: "Mất niềm tin, hy vọng", partOfSpeech: "Tính từ", frequency: "TB" },
  ],
  transportation: [
    { word: "Xe máy", shortDef: "Phương tiện giao thông hai bánh có động cơ", partOfSpeech: "Danh từ", frequency: "Cao" },
    { word: "Ô tô", shortDef: "Xe hơi bốn bánh động cơ", partOfSpeech: "Danh từ", frequency: "Cao" },
    { word: "Máy bay", shortDef: "Phương tiện bay trên không", partOfSpeech: "Danh từ", frequency: "Cao" },
    { word: "Tàu hỏa", shortDef: "Xe lửa chạy trên đường ray", partOfSpeech: "Danh từ", frequency: "TB" },
    { word: "Xe buýt", shortDef: "Xe khách công cộng", partOfSpeech: "Danh từ", frequency: "Cao" },
    { word: "Xe đạp", shortDef: "Phương tiện hai bánh không động cơ", partOfSpeech: "Danh từ", frequency: "Cao" },
  ],
};

const mockWordData = {
  "vui vẻ": {
    id: "VV-001482",
    word: "Vui vẻ",
    pronunciation: "vui vẻ",
    partOfSpeech: "Tính từ",
    frequency: "Cao",
    register: "Trung tính",
    etymology: "Từ gốc Hán-Việt, kết hợp giữa 'vui' (快) và 'vẻ' (美)",
    meanings: [
      "Có tâm trạng vui, sung sướng, phấn khởi; thể hiện sự hài lòng và tích cực",
      "Thái độ niềm nở, dễ chịu, không buồn bực; cách cư xử thân thiện",
      "Bầu không khí hoặc tình huống tạo cảm giác thoải mái, tích cực",
    ],
    examples: [
      "Cô ấy luôn vui vẻ với mọi người trong công việc.",
      "Hôm nay tôi cảm thấy rất vui vẻ sau khi nhận được tin tốt.",
      "Buổi gặp mặt diễn ra trong không khí vui vẻ và thân mật.",
    ],
    synonyms: [
      { word: "Vui sướng", intensity: 85, frequency: "Cao", note: "Mức độ vui cao hơn" },
      { word: "Hoan hỉ", intensity: 75, frequency: "TB", note: "Văn phong trang trọng" },
      { word: "Phấn khởi", intensity: 70, frequency: "TB", note: "Nhấn mạnh sự hứng khởi" },
      { word: "Vui tươi", intensity: 65, frequency: "Cao", note: "Thể hiện bề ngoài" },
      { word: "Tươi cười", intensity: 50, frequency: "TB", note: "Tập trung vào nét mặt" },
      { word: "Hài lòng", intensity: 40, frequency: "Cao", note: "Sự thoả mãn nhẹ" },
      { word: "Vừa lòng", intensity: 25, frequency: "TB", note: "Mức độ thoả mãn thấp" },
    ],
    idioms: [
      { 
        phrase: "Vui như Tết", 
        meaning: "Rất vui vẻ, phấn khởi như trong dịp lễ Tết",
        usage: "Dùng trong văn nói, thể hiện mức độ vui cao"
      },
      { 
        phrase: "Cười như được mùa", 
        meaning: "Vui vẻ, hài lòng vì có được điều mong muốn",
        usage: "Thường dùng khi đạt được mục tiêu"
      },
    ],
    relatedWords: ["Hạnh phúc", "Phấn khích", "Vui mừng", "Hân hoan"],
  },
  "buồn bã": {
    id: "BB-002137",
    word: "Buồn bã",
    pronunciation: "buồn bã",
    partOfSpeech: "Tính từ",
    frequency: "Cao",
    register: "Trung tính",
    etymology: "Từ ghép đơn thuần tiếng Việt, 'buồn' kết hợp 'bã' (tăng cường nghĩa)",
    meanings: [
      "Tâm trạng u buồn, không vui; trạng thái tinh thần tiêu cực",
      "Cảm giác không thoải mái về tinh thần, có phần nặng nề",
    ],
    examples: [
      "Anh ấy trông buồn bã sau khi nhận tin xấu từ gia đình.",
      "Thời tiết u ám làm tôi cảm thấy buồn bã cả ngày.",
    ],
    synonyms: [
      { word: "Sầu khổ", intensity: 90, frequency: "TB", note: "Mức độ đau buồn rất cao" },
      { word: "Đau buồn", intensity: 85, frequency: "Cao", note: "Nỗi buồn sâu sắc" },
      { word: "Bi thương", intensity: 75, frequency: "Thấp", note: "Văn phong cao" },
      { word: "Ủ rũ", intensity: 60, frequency: "TB", note: "Thể hiện bề ngoài" },
      { word: "Sầu muộn", intensity: 55, frequency: "Thấp", note: "Văn phong trang trọng" },
      { word: "Ưu phiền", intensity: 45, frequency: "TB", note: "Lo nghĩ, băn khoăn" },
      { word: "Không vui", intensity: 30, frequency: "Cao", note: "Mức độ nhẹ nhất" },
    ],
    idioms: [
      { 
        phrase: "Buồn như chó mất đũa", 
        meaning: "Rất buồn, thất vọng một cách vô lý",
        usage: "Dùng trong văn nói, mang tính hài hước"
      },
    ],
    relatedWords: ["Thất vọng", "Chán nản", "U sầu", "Phiền muộn"],
  },
  "xe máy": {
    id: "XM-003891",
    word: "Xe máy",
    pronunciation: "xe máy",
    partOfSpeech: "Danh từ",
    frequency: "Rất cao",
    register: "Trung tính",
    etymology: "Từ ghép: 'xe' (phương tiện) + 'máy' (có động cơ cơ khí)",
    meanings: [
      "Phương tiện giao thông cá nhân hai bánh được trang bị động cơ",
      "Loại xe được điều khiển bằng tay ga, phanh và lái; di chuyển bằng động cơ đốt trong",
    ],
    examples: [
      "Tôi đi làm bằng xe máy mỗi ngày vì tiện lợi và nhanh chóng.",
      "Xe máy là phương tiện giao thông phổ biến nhất ở Việt Nam.",
      "Anh ấy vừa mua một chiếc xe máy mới với công nghệ tiên tiến.",
    ],
    synonyms: [
      { word: "Mô tô", intensity: 95, frequency: "Cao", note: "Từ vay mượn từ tiếng Pháp" },
      { word: "Xe gắn máy", intensity: 85, frequency: "TB", note: "Thuật ngữ kỹ thuật" },
      { word: "Xe hai bánh", intensity: 60, frequency: "TB", note: "Mô tả đặc điểm vật lý" },
    ],
    idioms: [],
    relatedWords: ["Ô tô", "Xe đạp", "Xe scooter", "Giao thông"],
  },
  "hạnh phúc": {
    id: "HP-001203",
    word: "Hạnh phúc",
    pronunciation: "hạnh phúc",
    partOfSpeech: "Tính từ / Danh từ",
    frequency: "Rất cao",
    register: "Trung tính",
    etymology: "Từ Hán-Việt: 幸福 (hạnh phúc), nghĩa gốc là 'may mắn và phúc lộc'",
    meanings: [
      "Trạng thái cảm xúc tích cực cao, sự thoả mãn sâu sắc về tinh thần và vật chất",
      "Điều kiện sống tốt đẹp, đầy đủ và êm ấm",
      "Cảm giác bình an, sung sướng trong tâm hồn",
    ],
    examples: [
      "Gia đình tôi đang sống rất hạnh phúc ở vùng quê yên bình.",
      "Hạnh phúc không chỉ là có tiền mà còn là sức khỏe và tình yêu.",
    ],
    synonyms: [
      { word: "Sung sướng", intensity: 85, frequency: "Cao", note: "Nhấn mạnh sự thoả mãn cao" },
      { word: "An vui", intensity: 70, frequency: "TB", note: "Sự yên bình và vui vẻ" },
      { word: "Êm ấm", intensity: 60, frequency: "Cao", note: "Tập trung vào sự ấm áp" },
      { word: "Mãn nguyện", intensity: 55, frequency: "TB", note: "Được như ý muốn" },
      { word: "Thoải mái", intensity: 40, frequency: "Rất cao", note: "Không áp lực" },
    ],
    idioms: [
      { 
        phrase: "Hạnh phúc viên mãn", 
        meaning: "Hạnh phúc trọn vẹn, đầy đủ mọi mặt",
        usage: "Văn phong trang trọng"
      },
    ],
    relatedWords: ["Vui vẻ", "An lạc", "Bình yên", "Thoả mãn"],
  },
};

type Screen = 
  | { type: "home" }
  | { type: "word-detail"; word: string }
  | { type: "topic"; topicId: string };

export default function App() {
  const [screen, setScreen] = useState<Screen>({ type: "home" });
  const [searchValue, setSearchValue] = useState("");
  const [recentWords, setRecentWords] = useState(["Vui vẻ", "Buồn bã", "Hạnh phúc"]);

  const totalWords = Object.keys(mockWordData).length + 
    mockTopics.reduce((sum, topic) => sum + topic.wordCount, 0);

  const handleSearch = () => {
    if (searchValue.trim()) {
      const wordKey = searchValue.toLowerCase().trim();
      if (mockWordData[wordKey as keyof typeof mockWordData]) {
        // Add to recent words
        setRecentWords(prev => {
          const filtered = prev.filter(w => w.toLowerCase() !== wordKey);
          return [searchValue, ...filtered].slice(0, 5);
        });
        setScreen({ type: "word-detail", word: wordKey });
      }
    }
  };

  const handleWordClick = (word: string) => {
    const wordKey = word.toLowerCase();
    if (mockWordData[wordKey as keyof typeof mockWordData]) {
      setSearchValue(word);
      // Add to recent words
      setRecentWords(prev => {
        const filtered = prev.filter(w => w.toLowerCase() !== wordKey);
        return [word, ...filtered].slice(0, 5);
      });
      setScreen({ type: "word-detail", word: wordKey });
    }
  };

  const handleTopicClick = (topicId: string) => {
    setScreen({ type: "topic", topicId });
  };

  const handleBack = () => {
    setScreen({ type: "home" });
  };

  return (
    <div className="size-full flex items-center justify-center bg-gradient-to-br from-blue-100 via-purple-100 to-pink-100">
      {/* Mobile container - Flutter Scaffold equivalent */}
      <div className="w-full h-full max-w-md bg-white overflow-y-auto shadow-2xl border-4 border-blue-200 rounded-lg">
        {screen.type === "home" && (
          <HomeScreen
            searchValue={searchValue}
            onSearchChange={setSearchValue}
            onSearchSubmit={handleSearch}
            topics={mockTopics}
            onTopicClick={handleTopicClick}
            recentWords={recentWords}
            onRecentWordClick={handleWordClick}
            totalWords={totalWords}
          />
        )}

        {screen.type === "word-detail" && (
          <WordDetail
            wordData={mockWordData[screen.word as keyof typeof mockWordData]}
            onBack={handleBack}
            onWordClick={handleWordClick}
          />
        )}

        {screen.type === "topic" && mockTopicWords[screen.topicId] && (
          <TopicWords
            topicName={mockTopics.find(t => t.id === screen.topicId)?.name || ""}
            topicId={screen.topicId}
            words={mockTopicWords[screen.topicId]}
            onBack={handleBack}
            onWordClick={handleWordClick}
          />
        )}
      </div>
    </div>
  );
}