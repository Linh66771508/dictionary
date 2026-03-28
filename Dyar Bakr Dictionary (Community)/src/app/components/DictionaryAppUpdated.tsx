import { useState, useEffect } from 'react';
import { Search, BookOpen, Share2, Globe, User } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { WordCard } from '@/app/components/WordCard';
import { WordDetail } from '@/app/components/WordDetail';
import { WelcomeSplash } from '@/app/components/WelcomeSplash';
import { FounderPage } from '@/app/components/FounderPage';
import { dictionaryData } from '@/app/data/dictionaryData';
import { additionalWords } from '@/app/data/dictionary-extended';
import type { DictionaryWord } from '@/app/data/dictionaryData';
import logo from 'figma:asset/8f4b2013606a1f72cb143375103c1f61024f0609.png';

// Merge all dictionary data
const allWords = [...dictionaryData, ...additionalWords];

export function DictionaryAppUpdated() {
  const [showSplash, setShowSplash] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedWord, setSelectedWord] = useState<DictionaryWord | null>(null);
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [showFounderPage, setShowFounderPage] = useState(false);
  const [language, setLanguage] = useState<'en' | 'ku'>('en');

  const categories = ['all', 'common', 'legal', 'literature', 'science', 'business', 'nature', 'emotions'];

  const filteredWords = allWords.filter(word => {
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
      navigator.clipboard.writeText(window.location.href);
      alert(language === 'ku' ? 'لینک کۆپی کرا!' : 'Link copied to clipboard!');
    }
  };

  const toggleLanguage = () => {
    setLanguage(prev => prev === 'en' ? 'ku' : 'en');
  };

  const uiText = {
    en: {
      title: "Dyar Bakr Dictionary",
      subtitle: `English to Kurdish Sorani • ${allWords.length}+ Words`,
      search: "Search for a word in English or Kurdish...",
      wordsFound: "words found",
      selectWord: "Select a word to view details",
      aboutFounder: "About Founder",
      share: "Share",
      back: "Back to Dictionary"
    },
    ku: {
      title: "فەرهەنگی دیار بەکر",
      subtitle: `ئینگلیزی بۆ کوردی (سۆرانی) • ${allWords.length}+ وشە`,
      search: "گەڕان بەدوای وشەیەکدا بە ئینگلیزی یان کوردی...",
      wordsFound: "وشە دۆزرایەوە",
      selectWord: "وشەیەک هەڵبژێرە بۆ بینینی وردەکاریەکان",
      aboutFounder: "دەربارەی دامەزرێنەر",
      share: "هاوبەشکردن",
      back: "گەڕانەوە بۆ فەرهەنگ"
    }
  };

  const ui = uiText[language];
  const isKurdish = language === 'ku';

  if (showSplash) {
    return <WelcomeSplash onComplete={() => setShowSplash(false)} />;
  }

  if (showFounderPage) {
    return <FounderPage onClose={() => setShowFounderPage(false)} language={language} />;
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#0a1929] via-[#1a237e] to-[#0a1929]">
      {/* Animated Background Pattern */}
      <div className="fixed inset-0 opacity-10">
        <div className="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHZpZXdCb3g9IjAgMCA2MCA2MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48ZyBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPjxnIGZpbGw9IiNGRkQ3MDAiIGZpbGwtb3BhY2l0eT0iMC40Ij48cGF0aCBkPSJNMzYgMzRjMC0yLjIxLTEuNzktNC00LTRzLTQgMS43OS00IDQgMS43OSA0IDQgNCA0LTEuNzkgNC00em0wLTEwYzAtMi4yMS0xLjc5LTQtNC00cy00IDEuNzktNCA0IDEuNzkgNCA0IDQgNC0xLjc5IDQtNHptMC0xMGMwLTIuMjEtMS43OS00LTQtNHMtNCAxLjc5LTQgNCAxLjc5IDQgNCA0IDQtMS43OSA0LTR6Ii8+PC9nPjwvZz48L3N2Zz4=')] animate-pulse"></div>
      </div>

      {/* Header */}
      <motion.header
        initial={{ y: -100 }}
        animate={{ y: 0 }}
        transition={{ duration: 0.6, type: "spring" }}
        className="relative bg-gradient-to-r from-[#1a237e] via-[#0d47a1] to-[#1a237e] shadow-2xl border-b-4 border-[#FFD700]"
      >
        <div className="max-w-7xl mx-auto px-4 py-8">
          <div className="flex items-center justify-between flex-wrap gap-4">
            <motion.div
              className="flex items-center gap-4"
              whileHover={{ scale: 1.02 }}
            >
              <motion.img
                src={logo}
                alt="Logo"
                className="w-16 h-16 object-contain"
                animate={{ rotate: [0, 5, -5, 0] }}
                transition={{ duration: 2, repeat: Infinity, repeatDelay: 3 }}
              />
              <div className={isKurdish ? 'kurdish-text' : ''}>
                <h1 className="text-4xl md:text-5xl font-bold text-[#FFD700] tracking-tight">
                  {ui.title}
                </h1>
                <p className="text-[#B8860B] text-sm md:text-base mt-1">{ui.subtitle}</p>
              </div>
            </motion.div>

            <div className="flex gap-3 flex-wrap">
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                onClick={toggleLanguage}
                className={`px-6 py-3 bg-white/20 backdrop-blur-sm text-[#FFD700] rounded-xl font-medium hover:bg-white/30 transition-all shadow-lg border border-[#FFD700]/30 flex items-center gap-2 ${isKurdish ? 'kurdish-text' : ''}`}
              >
                <Globe className="size-5" />
                {language === 'en' ? 'کوردی' : 'English'}
              </motion.button>

              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => setShowFounderPage(true)}
                className={`px-6 py-3 bg-white/20 backdrop-blur-sm text-[#FFD700] rounded-xl font-medium hover:bg-white/30 transition-all shadow-lg border border-[#FFD700]/30 flex items-center gap-2 ${isKurdish ? 'kurdish-text' : ''}`}
              >
                <User className="size-5" />
                {ui.aboutFounder}
              </motion.button>

              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                onClick={handleShare}
                className={`px-6 py-3 bg-gradient-to-r from-[#FFD700] to-[#FFC700] text-[#0a1929] rounded-xl font-semibold hover:from-[#FFC700] hover:to-[#FFB700] transition-all shadow-lg flex items-center gap-2 ${isKurdish ? 'kurdish-text' : ''}`}
              >
                <Share2 className="size-5" />
                {ui.share}
              </motion.button>
            </div>
          </div>
        </div>
      </motion.header>

      {/* Main Content */}
      <div className="relative max-w-7xl mx-auto px-4 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Left Panel - Search and Word List */}
          <div className="lg:col-span-2 space-y-4">
            {/* Search Bar */}
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.2 }}
              className="bg-white/10 backdrop-blur-md rounded-2xl shadow-2xl p-6 border border-[#FFD700]/20"
            >
              <div className="relative">
                <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 text-[#FFD700] size-6" />
                <input
                  type="text"
                  placeholder={ui.search}
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className={`w-full pl-14 pr-6 py-4 bg-white/90 border-2 border-[#FFD700]/50 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#FFD700] focus:border-transparent text-gray-800 placeholder-gray-500 text-lg shadow-inner ${isKurdish ? 'kurdish-text' : ''}`}
                />
              </div>
            </motion.div>

            {/* Category Filter */}
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.3 }}
              className="bg-white/10 backdrop-blur-md rounded-2xl shadow-2xl p-6 border border-[#FFD700]/20"
            >
              <div className="flex flex-wrap gap-3">
                {categories.map((category, index) => (
                  <motion.button
                    key={category}
                    initial={{ opacity: 0, scale: 0.8 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ delay: 0.4 + index * 0.05 }}
                    whileHover={{ scale: 1.1, y: -2 }}
                    whileTap={{ scale: 0.95 }}
                    onClick={() => setSelectedCategory(category)}
                    className={`px-5 py-2.5 rounded-full text-sm font-semibold transition-all shadow-lg ${
                      selectedCategory === category
                        ? 'bg-gradient-to-r from-[#FFD700] to-[#FFC700] text-[#0a1929] shadow-[#FFD700]/50'
                        : 'bg-white/80 text-gray-700 hover:bg-white hover:shadow-xl'
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
              className={`text-[#FFD700] text-sm px-2 font-medium ${isKurdish ? 'kurdish-text' : ''}`}
            >
              {filteredWords.length} {ui.wordsFound}
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
                  className="bg-white/10 backdrop-blur-md rounded-2xl shadow-2xl p-12 text-center border border-[#FFD700]/20"
                >
                  <motion.div
                    animate={{ y: [0, -10, 0] }}
                    transition={{ duration: 2, repeat: Infinity }}
                  >
                    <BookOpen className="size-20 text-[#FFD700]/50 mx-auto mb-6" />
                  </motion.div>
                  <p className={`text-[#FFD700] text-lg ${isKurdish ? 'kurdish-text' : ''}`}>
                    {ui.selectWord}
                  </p>
                </motion.div>
              )}
            </motion.div>
          </div>
        </div>
      </div>
    </div>
  );
}
