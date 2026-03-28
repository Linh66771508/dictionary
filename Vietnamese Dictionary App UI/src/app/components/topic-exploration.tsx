import { ChevronRight } from "lucide-react";

interface Topic {
  id: string;
  name: string;
  wordCount: number;
  icon: string;
}

interface TopicExplorationProps {
  topics: Topic[];
  onTopicClick: (topicId: string) => void;
}

const topicColors: Record<string, { bg: string; border: string; iconBg: string }> = {
  emotions: { bg: "bg-pink-50", border: "border-pink-300", iconBg: "bg-gradient-to-br from-pink-400 to-rose-500" },
  transportation: { bg: "bg-blue-50", border: "border-blue-300", iconBg: "bg-gradient-to-br from-blue-400 to-cyan-500" },
  food: { bg: "bg-orange-50", border: "border-orange-300", iconBg: "bg-gradient-to-br from-orange-400 to-amber-500" },
  nature: { bg: "bg-green-50", border: "border-green-300", iconBg: "bg-gradient-to-br from-green-400 to-emerald-500" },
  work: { bg: "bg-purple-50", border: "border-purple-300", iconBg: "bg-gradient-to-br from-purple-400 to-indigo-500" },
  family: { bg: "bg-yellow-50", border: "border-yellow-300", iconBg: "bg-gradient-to-br from-yellow-400 to-orange-400" },
};

export function TopicExploration({ topics, onTopicClick }: TopicExplorationProps) {
  return (
    <div className="space-y-3">
      {topics.map((topic) => {
        const colors = topicColors[topic.id] || { bg: "bg-gray-50", border: "border-gray-300", iconBg: "bg-gray-400" };
        return (
          <button
            key={topic.id}
            onClick={() => onTopicClick(topic.id)}
            className={`w-full ${colors.bg} border-2 ${colors.border} rounded-xl p-4 hover:shadow-lg hover:scale-[1.02] transition-all shadow-sm`}
          >
            {/* Row layout */}
            <div className="flex items-center gap-4">
              {/* Icon container */}
              <div className={`size-14 ${colors.iconBg} rounded-xl flex items-center justify-center text-2xl shrink-0 shadow-md`}>
                {topic.icon}
              </div>
              
              {/* Text column */}
              <div className="flex-1 text-left">
                <div className="font-bold text-gray-900 mb-1">{topic.name}</div>
                <div className="text-sm text-gray-600">{topic.wordCount} từ</div>
              </div>
              
              {/* Arrow icon */}
              <ChevronRight className="size-6 text-gray-400 shrink-0" />
            </div>
          </button>
        );
      })}
    </div>
  );
}
