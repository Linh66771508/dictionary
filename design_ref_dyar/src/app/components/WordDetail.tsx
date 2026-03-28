import { useState } from 'react';
import { motion } from 'motion/react';
import { Volume2, BookOpen, ArrowRightLeft, ImageIcon } from 'lucide-react';
import { type DictionaryWord } from '@/app/data/dictionaryData';

interface WordDetailProps {
  word: DictionaryWord;
}

export function WordDetail({ word }: WordDetailProps) {
  const [imageError, setImageError] = useState(false);
  const [imageLoading, setImageLoading] = useState(true);

  // Use Unsplash API with proper URL format
  const imageUrl = `https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?w=800&h=600&fit=crop&q=80`;

  const speakWord = () => {
    if ('speechSynthesis' in window) {
      const utterance = new SpeechSynthesisUtterance(word.english);
      utterance.lang = 'en-US';
      window.speechSynthesis.speak(utterance);
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ duration: 0.3 }}
      className="bg-gradient-to-br from-[#F5F5DC]/98 to-white/95 backdrop-blur-md rounded-2xl shadow-2xl p-6 space-y-6 border-2 border-[#D4AF37]/50"
    >
      {/* Word Image */}
      <motion.div 
        className="relative w-full h-56 rounded-xl overflow-hidden bg-gradient-to-br from-[#D4AF37]/20 to-[#800020]/10 shadow-inner border-2 border-[#D4AF37]/30"
        whileHover={{ scale: 1.02 }}
        transition={{ duration: 0.3 }}
      >
        {!imageError ? (
          <>
            {imageLoading && (
              <div className="absolute inset-0 flex items-center justify-center">
                <motion.div
                  animate={{ rotate: 360 }}
                  transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
                  className="size-12 border-4 border-[#800020] border-t-[#D4AF37] rounded-full"
                />
              </div>
            )}
            <img
              src={imageUrl}
              alt={word.english}
              className="w-full h-full object-cover"
              onError={() => {
                setImageError(true);
                setImageLoading(false);
              }}
              onLoad={() => setImageLoading(false)}
            />
          </>
        ) : (
          <div className="flex flex-col items-center justify-center h-full">
            <ImageIcon className="size-16 text-[#D4AF37] mb-2" />
            <p className="text-[#800020] text-sm font-semibold">Image not available</p>
          </div>
        )}
      </motion.div>

      {/* Main Word */}
      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <motion.h2
            initial={{ x: -20 }}
            animate={{ x: 0 }}
            className="text-3xl font-bold text-[#1a1a2e]"
          >
            {word.english}
          </motion.h2>
          <motion.button
            whileHover={{ scale: 1.1, boxShadow: '0 0 20px rgba(212, 175, 55, 0.5)' }}
            whileTap={{ scale: 0.9 }}
            onClick={speakWord}
            className="p-3 rounded-full bg-gradient-to-r from-[#800020] to-[#a02040] hover:from-[#a02040] hover:to-[#c02850] transition-all shadow-lg border-2 border-[#D4AF37]/50"
            title="Pronounce word"
          >
            <Volume2 className="size-6 text-[#D4AF37]" />
          </motion.button>
        </div>
        
        <div className="space-y-2">
          <motion.p
            initial={{ x: 20 }}
            animate={{ x: 0 }}
            className="text-2xl text-[#800020] font-bold"
            dir="rtl"
          >
            {word.kurdish}
          </motion.p>
          <p className="text-sm text-gray-700 italic font-medium">/{word.pronunciation}/</p>
        </div>
      </div>

      {/* Category Badge */}
      <div>
        <motion.span
          whileHover={{ scale: 1.05, rotate: 2 }}
          className="inline-block px-4 py-2 bg-gradient-to-r from-[#800020] to-[#a02040] text-[#D4AF37] rounded-full text-sm font-bold shadow-lg border-2 border-[#D4AF37]/50"
        >
          {word.category.toUpperCase()}
        </motion.span>
      </div>

      {/* Synonyms */}
      {word.synonyms.length > 0 && (
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="space-y-2"
        >
          <h3 className="text-sm font-bold text-[#800020] uppercase tracking-wide">Synonyms</h3>
          <div className="flex flex-wrap gap-2">
            {word.synonyms.map((synonym, index) => (
              <motion.span
                key={index}
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: 0.2 + index * 0.05 }}
                whileHover={{ scale: 1.1, y: -2, boxShadow: '0 5px 15px rgba(34, 139, 34, 0.3)' }}
                className="px-3 py-1.5 bg-gradient-to-r from-emerald-100 to-green-50 text-emerald-800 rounded-full text-sm border-2 border-emerald-300 font-semibold shadow-sm"
              >
                {synonym}
              </motion.span>
            ))}
          </div>
        </motion.div>
      )}

      {/* Antonyms */}
      {word.antonyms.length > 0 && (
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="space-y-2"
        >
          <h3 className="text-sm font-bold text-[#800020] uppercase tracking-wide">Antonyms</h3>
          <div className="flex flex-wrap gap-2">
            {word.antonyms.map((antonym, index) => (
              <motion.span
                key={index}
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: 0.3 + index * 0.05 }}
                whileHover={{ scale: 1.1, y: -2, boxShadow: '0 5px 15px rgba(220, 38, 38, 0.3)' }}
                className="px-3 py-1.5 bg-gradient-to-r from-rose-100 to-red-50 text-rose-800 rounded-full text-sm border-2 border-rose-300 font-semibold shadow-sm"
              >
                {antonym}
              </motion.span>
            ))}
          </div>
        </motion.div>
      )}

      {/* Example Sentence */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3 }}
        className="space-y-3 pt-4 border-t-2 border-[#D4AF37]/50"
      >
        <div className="flex items-center gap-2">
          <BookOpen className="size-5 text-[#800020]" />
          <h3 className="text-sm font-bold text-[#800020] uppercase tracking-wide">Example</h3>
        </div>
        
        <div className="space-y-3">
          <motion.div
            whileHover={{ scale: 1.02, boxShadow: '0 10px 20px rgba(59, 130, 246, 0.2)' }}
            className="p-4 bg-gradient-to-r from-blue-50 to-indigo-50 rounded-lg border-l-4 border-blue-600 shadow-md"
          >
            <p className="text-gray-800 italic font-medium">\"{word.exampleSentence}\"</p>
          </motion.div>
          
          <div className="flex items-center justify-center">
            <motion.div
              animate={{ 
                x: [0, 5, -5, 0],
                rotate: [0, 10, -10, 0]
              }}
              transition={{ duration: 2, repeat: Infinity }}
            >
              <ArrowRightLeft className="size-5 text-[#800020]" />
            </motion.div>
          </div>
          
          <motion.div
            whileHover={{ scale: 1.02, boxShadow: '0 10px 20px rgba(212, 175, 55, 0.2)' }}
            className="p-4 bg-gradient-to-l from-[#F5F5DC] to-amber-50 rounded-lg border-r-4 border-[#800020] shadow-md"
            dir="rtl"
          >
            <p className="text-gray-800 italic font-medium">\"{word.exampleTranslation}\"</p>
          </motion.div>
        </div>
      </motion.div>
    </motion.div>
  );
}