import { ArrowLeft, Volume2, BookOpen, MessageSquare, Lightbulb } from "lucide-react";
import { SynonymScale } from "./synonym-scale";

interface WordData {
  word: string;
  pronunciation?: string;
  partOfSpeech: string;
  meanings: string[];
  examples?: string[];
  synonyms: { word: string; intensity: number }[];
  idioms?: { phrase: string; meaning: string }[];
}

interface WordDetailProps {
  wordData: WordData;
  onBack: () => void;
}

export function WordDetail({ wordData, onBack }: WordDetailProps) {
  return (
    <div className="min-h-screen bg-gradient-to-b from-blue-50 to-purple-50">
      {/* AppBar - Flutter AppBar equivalent */}
      <div className="bg-gradient-to-r from-blue-600 to-purple-600 text-white shadow-lg">
        <div className="px-4 py-4 flex items-center gap-4">
          <button onClick={onBack} className="text-white hover:bg-white/20 p-1 rounded-lg transition-colors">
            <ArrowLeft className="size-6" />
          </button>
          <h2 className="text-lg font-medium">Chi tiết từ</h2>
        </div>
      </div>

      {/* Column layout - Flutter Column equivalent */}
      <div className="p-4 space-y-4">
        
        {/* Card 1: Word Header */}
        <div className="bg-white rounded-xl border-2 border-blue-200 p-5 shadow-md">
          <div className="flex items-start gap-3 mb-3">
            <h1 className="text-3xl font-bold text-gray-900 flex-1">{wordData.word}</h1>
            <button className="text-blue-600 hover:bg-blue-50 p-2 rounded-lg transition-colors">
              <Volume2 className="size-6" />
            </button>
          </div>
          
          {wordData.pronunciation && (
            <div className="text-blue-700 font-medium mb-3">/{wordData.pronunciation}/</div>
          )}
          
          <div className="inline-block px-4 py-2 bg-gradient-to-r from-blue-500 to-blue-600 text-white rounded-lg text-sm font-medium shadow-sm">
            {wordData.partOfSpeech}
          </div>
        </div>

        {/* Card 2: Meanings */}
        <div className="bg-white rounded-xl border-2 border-green-200 p-5 shadow-md">
          <div className="flex items-center gap-2 mb-4">
            <div className="p-2 bg-green-100 rounded-lg">
              <BookOpen className="size-5 text-green-600" />
            </div>
            <h3 className="font-bold text-gray-900">Nghĩa</h3>
          </div>
          <div className="space-y-3">
            {wordData.meanings.map((meaning, index) => (
              <div key={index} className="flex gap-3 bg-green-50 p-3 rounded-lg">
                <span className="text-green-600 font-bold shrink-0">{index + 1}.</span>
                <p className="text-gray-800">{meaning}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Card 3: Examples */}
        {wordData.examples && wordData.examples.length > 0 && (
          <div className="bg-white rounded-xl border-2 border-amber-200 p-5 shadow-md">
            <h3 className="font-bold text-gray-900 mb-4">Ví dụ</h3>
            <div className="space-y-3">
              {wordData.examples.map((example, index) => (
                <div key={index} className="bg-gradient-to-r from-amber-50 to-orange-50 rounded-lg p-4 border-l-4 border-amber-400">
                  <p className="text-gray-700 italic">{example}</p>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Card 4: Synonyms */}
        {wordData.synonyms.length > 0 && (
          <div className="bg-white rounded-xl border-2 border-purple-200 overflow-hidden shadow-md">
            <div className="px-5 py-4 bg-gradient-to-r from-purple-100 to-pink-100 border-b-2 border-purple-200">
              <div className="flex items-center gap-2">
                <div className="p-2 bg-purple-200 rounded-lg">
                  <MessageSquare className="size-5 text-purple-700" />
                </div>
                <h3 className="font-bold text-gray-900">Từ đồng nghĩa (Mạnh → Nhẹ)</h3>
              </div>
            </div>
            <SynonymScale synonyms={wordData.synonyms} />
          </div>
        )}

        {/* Card 5: Idioms */}
        {wordData.idioms && wordData.idioms.length > 0 && (
          <div className="bg-white rounded-xl border-2 border-teal-200 p-5 shadow-md">
            <div className="flex items-center gap-2 mb-4">
              <div className="p-2 bg-teal-100 rounded-lg">
                <Lightbulb className="size-5 text-teal-600" />
              </div>
              <h3 className="font-bold text-gray-900">Thành ngữ & Tục ngữ</h3>
            </div>
            <div className="space-y-3">
              {wordData.idioms.map((idiom, index) => (
                <div key={index} className="bg-gradient-to-r from-teal-50 to-cyan-50 rounded-xl p-4 border-2 border-teal-200">
                  <p className="font-bold text-gray-900 mb-2">{idiom.phrase}</p>
                  <p className="text-sm text-gray-700">{idiom.meaning}</p>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
