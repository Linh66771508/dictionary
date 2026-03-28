interface Synonym {
  word: string;
  intensity: number; // 0-100
}

interface SynonymScaleProps {
  synonyms: Synonym[];
}

export function SynonymScale({ synonyms }: SynonymScaleProps) {
  // Sort synonyms by intensity (strong to weak)
  const sortedSynonyms = [...synonyms].sort((a, b) => b.intensity - a.intensity);

  const getIntensityLabel = (intensity: number) => {
    if (intensity >= 80) return "Rất mạnh";
    if (intensity >= 60) return "Mạnh";
    if (intensity >= 40) return "Trung bình";
    if (intensity >= 20) return "Nhẹ";
    return "Rất nhẹ";
  };

  const getIntensityColor = (intensity: number) => {
    if (intensity >= 80) return "bg-gradient-to-r from-red-500 to-red-600";
    if (intensity >= 60) return "bg-gradient-to-r from-orange-500 to-orange-600";
    if (intensity >= 40) return "bg-gradient-to-r from-yellow-500 to-yellow-600";
    if (intensity >= 20) return "bg-gradient-to-r from-green-400 to-green-500";
    return "bg-gradient-to-r from-blue-400 to-blue-500";
  };

  const getBgColor = (intensity: number) => {
    if (intensity >= 80) return "bg-red-50 border-red-200";
    if (intensity >= 60) return "bg-orange-50 border-orange-200";
    if (intensity >= 40) return "bg-yellow-50 border-yellow-200";
    if (intensity >= 20) return "bg-green-50 border-green-200";
    return "bg-blue-50 border-blue-200";
  };

  const getTextColor = (intensity: number) => {
    if (intensity >= 80) return "text-red-700";
    if (intensity >= 60) return "text-orange-700";
    if (intensity >= 40) return "text-yellow-700";
    if (intensity >= 20) return "text-green-700";
    return "text-blue-700";
  };

  return (
    <div className="space-y-0">
      {sortedSynonyms.map((synonym, index) => (
        <div 
          key={index} 
          className={`border-b last:border-b-0 py-3 px-4 hover:bg-opacity-70 transition-colors ${getBgColor(synonym.intensity)}`}
        >
          {/* Row layout - Flutter Row equivalent */}
          <div className="flex items-center justify-between gap-4">
            {/* Word */}
            <div className="flex-1">
              <div className="text-base font-medium text-gray-900">{synonym.word}</div>
            </div>
            
            {/* Intensity indicator and label */}
            <div className="flex items-center gap-3 shrink-0">
              <div className={`text-sm font-medium ${getTextColor(synonym.intensity)}`}>
                {getIntensityLabel(synonym.intensity)}
              </div>
              <div className={`w-3 h-8 rounded-md ${getIntensityColor(synonym.intensity)} shadow-sm`} />
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}
