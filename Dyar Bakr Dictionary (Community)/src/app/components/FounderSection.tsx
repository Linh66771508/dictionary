import { motion } from 'motion/react';
import { Award, BookOpen, Camera, Palette, TrendingUp, Users } from 'lucide-react';

export function FounderSection() {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6 }}
      className="bg-gradient-to-br from-[#F5F5DC] via-white to-[#F5F5DC] rounded-2xl shadow-2xl p-8 border-2 border-[#D4AF37]/50"
    >
      {/* Header */}
      <div className="text-center mb-8">
        <motion.div
          initial={{ scale: 0.9 }}
          animate={{ scale: 1 }}
          transition={{ duration: 0.5 }}
          className="inline-block"
        >
          <h2 className="text-3xl font-bold bg-gradient-to-r from-[#800020] via-[#a02040] to-[#800020] bg-clip-text text-transparent mb-2">
            Founder & Visionary
          </h2>
          <div className="h-1 w-32 bg-gradient-to-r from-transparent via-[#D4AF37] to-transparent mx-auto"></div>
        </motion.div>
      </div>

      {/* Founder Info */}
      <div className="max-w-3xl mx-auto">
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.3, duration: 0.6 }}
          className="bg-white/90 backdrop-blur-sm rounded-xl p-6 shadow-lg border-2 border-[#D4AF37]/30"
        >
          <h3 className="text-2xl font-bold text-[#1a1a2e] mb-4 text-center">
            Dyar Bakr Kako
          </h3>
          
          <p className="text-gray-700 leading-relaxed mb-6 text-center italic">
            Born in Erbil (2004)
          </p>

          <div className="prose prose-amber max-w-none text-gray-700 leading-relaxed mb-6">
            <p>
              At the pinnacle of this dictionary stands <span className="font-bold text-[#800020]">Dyar Bakr Kako</span>, 
              a visionary polymath born in Erbil. An intellectual powerhouse, he translated Leo Tolstoy's masterpiece 
              <span className="italic"> 'God Sees the Truth, But Waits'</span> into Kurdish and pioneered cinematography 
              translations for KurdSubtitle, including <span className="italic">'Infested'</span> and <span className="italic">'Imaginary'</span>.
            </p>
            <p className="mt-4">
              Beyond literature, Dyar is a certified SketchUp specialist, elite graphic designer, and digital marketing mogul. 
              His formidable background as a former CFO in full finance ensures exceptional organizational excellence.
            </p>
          </div>

          {/* Skills Grid */}
          <div className="grid grid-cols-2 md:grid-cols-3 gap-4 mt-6">
            <motion.div
              whileHover={{ scale: 1.05, boxShadow: '0 10px 20px rgba(212, 175, 55, 0.3)' }}
              className="flex items-center gap-2 bg-gradient-to-br from-[#D4AF37]/20 to-[#F5F5DC] p-3 rounded-lg shadow-sm border border-[#D4AF37]/30"
            >
              <BookOpen className="size-5 text-[#800020]" />
              <span className="text-sm font-bold text-gray-700">Literary Translation</span>
            </motion.div>

            <motion.div
              whileHover={{ scale: 1.05, boxShadow: '0 10px 20px rgba(212, 175, 55, 0.3)' }}
              className="flex items-center gap-2 bg-gradient-to-br from-[#D4AF37]/20 to-[#F5F5DC] p-3 rounded-lg shadow-sm border border-[#D4AF37]/30"
            >
              <Camera className="size-5 text-[#800020]" />
              <span className="text-sm font-bold text-gray-700">Cinematography</span>
            </motion.div>

            <motion.div
              whileHover={{ scale: 1.05, boxShadow: '0 10px 20px rgba(212, 175, 55, 0.3)' }}
              className="flex items-center gap-2 bg-gradient-to-br from-[#D4AF37]/20 to-[#F5F5DC] p-3 rounded-lg shadow-sm border border-[#D4AF37]/30"
            >
              <Palette className="size-5 text-[#800020]" />
              <span className="text-sm font-bold text-gray-700">Graphic Design</span>
            </motion.div>

            <motion.div
              whileHover={{ scale: 1.05, boxShadow: '0 10px 20px rgba(212, 175, 55, 0.3)' }}
              className="flex items-center gap-2 bg-gradient-to-br from-[#D4AF37]/20 to-[#F5F5DC] p-3 rounded-lg shadow-sm border border-[#D4AF37]/30"
            >
              <TrendingUp className="size-5 text-[#800020]" />
              <span className="text-sm font-bold text-gray-700">Digital Marketing</span>
            </motion.div>

            <motion.div
              whileHover={{ scale: 1.05, boxShadow: '0 10px 20px rgba(212, 175, 55, 0.3)' }}
              className="flex items-center gap-2 bg-gradient-to-br from-[#D4AF37]/20 to-[#F5F5DC] p-3 rounded-lg shadow-sm border border-[#D4AF37]/30"
            >
              <Award className="size-5 text-[#800020]" />
              <span className="text-sm font-bold text-gray-700">SketchUp Certified</span>
            </motion.div>

            <motion.div
              whileHover={{ scale: 1.05, boxShadow: '0 10px 20px rgba(212, 175, 55, 0.3)' }}
              className="flex items-center gap-2 bg-gradient-to-br from-[#D4AF37]/20 to-[#F5F5DC] p-3 rounded-lg shadow-sm border border-[#D4AF37]/30"
            >
              <Users className="size-5 text-[#800020]" />
              <span className="text-sm font-bold text-gray-700">Former CFO</span>
            </motion.div>
          </div>
        </motion.div>
      </div>
    </motion.div>
  );
}