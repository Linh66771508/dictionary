import { ArrowLeft } from "lucide-react";

interface Word {
  word: string;
  shortDef: string;
  partOfSpeech: string;
}

interface TopicWordsProps {
  topicName: string;
  topicId?: string;
  words: Word[];
  onBack: () => void;
  onWordClick: (word: string) => void;
}

const topicGradients: Record<string, string> = {
  emotions: "from-pink-500 to-rose-600",
  transportation: "from-blue-500 to-cyan-600",
  food: "from-orange-500 to-amber-600",
  nature: "from-green-500 to-emerald-600",
  work: "from-purple-500 to-indigo-600",
  family: "from-yellow-500 to-orange-500",
};

export function TopicWords({ topicName, topicId = "emotions", words, onBack, onWordClick }: TopicWordsProps) {
  const gradient = topicGradients[topicId] || "from-blue-500 to-purple-600";

  return (
    <div className="min-h-screen bg-gradient-to-b from-blue-50 to-purple-50">
      {/* AppBar */}
      <div className={`bg-gradient-to-r ${gradient} text-white shadow-lg`}>
        <div className="px-4 py-4 flex items-center gap-4">
          <button onClick={onBack} className="text-white hover:bg-white/20 p-1 rounded-lg transition-colors">
            <ArrowLeft className="size-6" />
          </button>
          <div className="flex-1">
            <h2 className="text-lg font-bold">{topicName}</h2>
            <p className="text-sm text-white/90">{words.length} từ</p>
          </div>
        </div>
      </div>

      {/* ListView - Flutter ListView equivalent */}
      <div className="p-4 space-y-3">
        {words.map((word, index) => (
          <button
            key={index}
            onClick={() => onWordClick(word.word)}
            className="w-full bg-white border-2 border-blue-200 rounded-xl p-4 text-left hover:shadow-lg hover:border-blue-400 hover:scale-[1.02] transition-all shadow-sm"
          >
            {/* Row for word and tag */}
            <div className="flex items-start justify-between gap-3 mb-2">
              <h4 className="font-bold text-gray-900">{word.word}</h4>
              <div className="px-3 py-1 bg-gradient-to-r from-blue-500 to-purple-500 text-white rounded-lg text-xs font-medium shrink-0 shadow-sm">
                {word.partOfSpeech}
              </div>
            </div>
            {/* Definition text */}
            <p className="text-sm text-gray-600">{word.shortDef}</p>
          </button>
        ))}
      </div>
    </div>
  );
}
