import { useState } from 'react';
import { Search, BookOpen, Share2 } from 'lucide-react';
import { motion } from 'motion/react';
import { WordCard } from '@/app/components/WordCard';
import { WordDetail } from '@/app/components/WordDetail';
import { FounderSection } from '@/app/components/FounderSection';
import { dictionaryData, type DictionaryWord } from '@/app/data/dictionaryData';

export function DictionaryApp() {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedWord, setSelectedWord] = useState<DictionaryWord | null>(null);
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [showFounder, setShowFounder] = useState(false);

  const categories = ['all', 'common', 'legal', 'literature', 'science', 'business', 'nature', 'emotions'];

  const filteredWords = dictionaryData.filter(word => {
    const matchesSearch = word.english.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         word.kurdish.includes(searchTerm);
    const matchesCategory = selectedCategory === 'all' || word.category === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  const handleShare = async () => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: 'Dyar Bakr Dictionary',
          text: 'Check out this comprehensive English-Kurdish Sorani Dictionary!',
          url: window.location.href,
        });
      } catch (err) {
        console.log('Share cancelled');
      }
    } else {
      // Fallback - copy to clipboard
      navigator.clipboard.writeText(window.location.href);
      alert('Link copied to clipboard!');
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#1a1a2e] via-[#16213e] to-[#0f0f1e]">
      {/* Animated Background Pattern */}
      <div className="fixed inset-0 opacity-5">
        <div className="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHZpZXdCb3g9IjAgMCA2MCA2MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48ZyBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPjxnIGZpbGw9IiNENEFGMzciIGZpbGwtb3BhY2l0eT0iMC40Ij48cGF0aCBkPSJNMzYgMzRjMC0yLjIxLTEuNzktNC00LTRzLTQgMS43OS00IDQgMS43OSA0IDQgNCA0LTEuNzkgNC00em0wLTEwYzAtMi4yMS0xLjc5LTQtNC00cy00IDEuNzktNCA0IDEuNzkgNCA0IDQgNC0xLjc5IDQtNHptMC0xMGMwLTIuMjEtMS43OS00LTQtNHMtNCAxLjc5LTQgNCAxLjc5IDQgNCA0IDQtMS43OSA0LTR6Ii8+PC9nPjwvZz48L3N2Zz4=')] animate-pulse"></div>
      </div>

      {/* Luxury Shine Effect */}
      <motion.div
        className="fixed inset-0 pointer-events-none"
        initial={{ opacity: 0 }}
        animate={{ opacity: [0, 0.1, 0] }}
        transition={{ duration: 3, repeat: Infinity, repeatDelay: 2 }}
      >
        <div className="absolute inset-0 bg-gradient-to-r from-transparent via-[#D4AF37]/10 to-transparent transform -skew-x-12" />
      </motion.div>

      {/* Header */}
      <motion.header
        initial={{ y: -100 }}
        animate={{ y: 0 }}
        transition={{ duration: 0.6, type: "spring" }}
        className="relative bg-gradient-to-r from-[#800020] via-[#a02040] to-[#800020] shadow-2xl border-b-4 border-[#D4AF37]"
      >
        <div className="max-w-7xl mx-auto px-4 py-8">
          <div className="flex items-center justify-between flex-wrap gap-4">
            <motion.div
              className="flex items-center gap-4"
              whileHover={{ scale: 1.02 }}
            >
              <motion.div
                animate={{ 
                  rotate: [0, 5, -5, 0],
                  scale: [1, 1.05, 1]
                }}
                transition={{ duration: 3, repeat: Infinity, repeatDelay: 2 }}
                className="relative"
              >
                <div className="absolute inset-0 bg-[#D4AF37]/30 rounded-full blur-xl" />
                <BookOpen className="size-12 text-[#D4AF37] relative z-10" />
              </motion.div>
              <div>
                <motion.h1 
                  className="text-4xl md:text-5xl font-bold text-[#F5F5DC] tracking-tight"
                  animate={{ 
                    textShadow: [
                      '0 0 20px rgba(212, 175, 55, 0.3)',
                      '0 0 30px rgba(212, 175, 55, 0.5)',
                      '0 0 20px rgba(212, 175, 55, 0.3)'
                    ]
                  }}
                  transition={{ duration: 2, repeat: Infinity }}
                >
                  Dyar Bakr Dictionary
                </motion.h1>
                <p className="text-[#D4AF37] text-sm md:text-base mt-1 font-medium">
                  English to Kurdish Sorani • {dictionaryData.length} Words
                </p>
              </div>
            </motion.div>

            <div className="flex gap-3">
              <motion.button
                whileHover={{ scale: 1.05, boxShadow: '0 0 20px rgba(212, 175, 55, 0.5)' }}
                whileTap={{ scale: 0.95 }}
                onClick={() => setShowFounder(!showFounder)}
                className="px-6 py-3 bg-gradient-to-r from-[#D4AF37] to-[#b8941f] backdrop-blur-sm text-[#1a1a2e] rounded-xl font-bold hover:from-[#e5c158] hover:to-[#D4AF37] transition-all shadow-lg border-2 border-[#D4AF37]/50"
              >
                {showFounder ? 'Hide' : 'About'} Founder
              </motion.button>

              <motion.button
                whileHover={{ scale: 1.05, boxShadow: '0 0 20px rgba(212, 175, 55, 0.5)' }}
                whileTap={{ scale: 0.95 }}
                onClick={handleShare}
                className="px-6 py-3 bg-gradient-to-r from-[#800020] to-[#600018] text-[#D4AF37] rounded-xl font-bold hover:from-[#a02040] hover:to-[#800020] transition-all shadow-lg flex items-center gap-2 border-2 border-[#D4AF37]/30"
              >
                <Share2 className="size-5" />
                Share
              </motion.button>
            </div>
          </div>
        </div>
      </motion.header>

      {/* Main Content */}
      <div className="relative max-w-7xl mx-auto px-4 py-8">
        {/* Founder Section */}
        {showFounder && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: "auto" }}
            exit={{ opacity: 0, height: 0 }}
            className="mb-8"
          >
            <FounderSection />
          </motion.div>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Left Panel - Search and Word List */}
          <div className="lg:col-span-2 space-y-4">
            {/* Search Bar */}
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.2 }}
              className="bg-gradient-to-br from-[#F5F5DC]/95 to-white/95 backdrop-blur-md rounded-2xl shadow-2xl p-6 border-2 border-[#D4AF37]/30"
            >
              <div className="relative">
                <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 text-[#800020] size-6" />
                <input
                  type="text"
                  placeholder="Search for a word in English or Kurdish..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="w-full pl-14 pr-6 py-4 bg-white border-2 border-[#D4AF37]/50 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#D4AF37] focus:border-transparent text-gray-800 placeholder-gray-500 text-lg shadow-inner"
                />
              </div>
            </motion.div>

            {/* Category Filter */}
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.3 }}
              className="bg-gradient-to-br from-[#F5F5DC]/95 to-white/95 backdrop-blur-md rounded-2xl shadow-2xl p-6 border-2 border-[#D4AF37]/30"
            >
              <div className="flex flex-wrap gap-3">
                {categories.map((category, index) => (
                  <motion.button
                    key={category}
                    initial={{ opacity: 0, scale: 0.8 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ delay: 0.4 + index * 0.05 }}
                    whileHover={{ scale: 1.1, y: -2, boxShadow: '0 10px 20px rgba(212, 175, 55, 0.3)' }}
                    whileTap={{ scale: 0.95 }}
                    onClick={() => setSelectedCategory(category)}
                    className={`px-5 py-2.5 rounded-full text-sm font-bold transition-all shadow-lg ${
                      selectedCategory === category
                        ? 'bg-gradient-to-r from-[#800020] to-[#a02040] text-[#D4AF37] shadow-[#800020]/50 border-2 border-[#D4AF37]'
                        : 'bg-gradient-to-r from-white to-[#F5F5DC] text-[#800020] hover:from-[#F5F5DC] hover:to-white border-2 border-[#D4AF37]/30'
                    }`}
                  >
                    {category.charAt(0).toUpperCase() + category.slice(1)}
                  </motion.button>
                ))}
              </div>
            </motion.div>

            {/* Word Count */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="text-[#D4AF37] text-sm px-2 font-bold"
            >
              {filteredWords.length} words found
            </motion.div>

            {/* Word List */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {filteredWords.map((word, index) => (
                <motion.div
                  key={word.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.03 }}
                >
                  <WordCard
                    word={word}
                    onClick={() => setSelectedWord(word)}
                    isSelected={selectedWord?.id === word.id}
                  />
                </motion.div>
              ))}
            </div>
          </div>

          {/* Right Panel - Word Details */}
          <div className="lg:col-span-1">
            <motion.div
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.4 }}
              className="sticky top-4"
            >
              {selectedWord ? (
                <WordDetail word={selectedWord} />
              ) : (
                <motion.div
                  initial={{ scale: 0.9 }}
                  animate={{ scale: 1 }}
                  className="bg-gradient-to-br from-[#F5F5DC]/95 to-white/95 backdrop-blur-md rounded-2xl shadow-2xl p-12 text-center border-2 border-[#D4AF37]/30"
                >
                  <motion.div
                    animate={{ 
                      y: [0, -10, 0],
                      rotate: [0, 5, -5, 0]
                    }}
                    transition={{ duration: 3, repeat: Infinity }}
                    className="relative inline-block"
                  >
                    <div className="absolute inset-0 bg-[#D4AF37]/20 rounded-full blur-2xl" />
                    <BookOpen className="size-20 text-[#800020]/50 relative z-10" />
                  </motion.div>
                  <p className="text-[#800020] text-lg font-semibold mt-6">Select a word to view details</p>
                </motion.div>
              )}
            </motion.div>
          </div>
        </div>
      </div>
    </div>
  );
}