import { motion } from 'motion/react';
import { type DictionaryWord } from '@/app/data/dictionaryData';

interface WordCardProps {
  word: DictionaryWord;
  onClick: () => void;
  isSelected: boolean;
}

export function WordCard({ word, onClick, isSelected }: WordCardProps) {
  return (
    <motion.button
      onClick={onClick}
      whileHover={{ scale: 1.03, y: -4, boxShadow: '0 20px 40px rgba(212, 175, 55, 0.3)' }}
      whileTap={{ scale: 0.98 }}
      className={`w-full bg-gradient-to-br from-[#F5F5DC]/95 to-white/90 backdrop-blur-sm rounded-xl shadow-lg p-5 text-left transition-all border-2 ${
        isSelected 
          ? 'ring-4 ring-[#D4AF37] border-[#800020] shadow-[#D4AF37]/50 shadow-2xl' 
          : 'border-[#D4AF37]/40 hover:shadow-2xl hover:border-[#D4AF37]'
      }`}
    >
      <div className="flex justify-between items-start gap-3">
        <div className="flex-1">
          <motion.h3
            className="font-bold text-[#1a1a2e] text-lg mb-1"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
          >
            {word.english}
          </motion.h3>
          <p className="text-[#800020] text-xl font-semibold mb-1" dir="rtl">{word.kurdish}</p>
          <p className="text-sm text-gray-600 italic">/{word.pronunciation}/</p>
        </div>
        <motion.span
          whileHover={{ scale: 1.1, rotate: 5 }}
          className="text-xs bg-gradient-to-r from-[#800020] to-[#a02040] text-[#D4AF37] px-3 py-1.5 rounded-full font-bold shadow-md border border-[#D4AF37]/50"
        >
          {word.category}
        </motion.span>
      </div>
    </motion.button>
  );
}