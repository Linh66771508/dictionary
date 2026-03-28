import { motion } from 'motion/react';
import { ArrowLeft, Award, Briefcase, GraduationCap, Languages, Film, Building2 } from 'lucide-react';

interface FounderPageProps {
  onClose: () => void;
  language: 'en' | 'ku';
}

export function FounderPage({ onClose, language }: FounderPageProps) {
  const content = {
    en: {
      title: "About the Founder",
      name: "Dyar Bakr Kako",
      born: "Born 2004, Erbil",
      bio: "Dyar Bakr Kako is a distinguished writer, translator, and polymath entrepreneur who has established a modern model of leadership and innovation in Kurdistan at a young age. As a talented English language student at Salahaddin University, Dyar notably translated Leo Tolstoy's masterpiece 'God Sees the Truth but Waits' into Kurdish and is recognized in the cinema world as a translator of international films on the KurdSubtitle platform (for films such as Infested and Imaginary).",
      business: "In the business and technology sphere, Dyar is a decisive force; he is the founder and owner of Crown Root Company for importing goods from abroad, as well as the creator of the Dyar Bakr Dictionary, a rich knowledge resource for Kurdish language and literature. This innovative young man, who owns the Dyar Bakr Brand, is an accomplished graphic designer and trusted SketchUp expert. Drawing on the solid foundation gained from experience as a former Chief Financial Officer (CFO), he has successfully led a digital marketing agency with a strategic vision, creating a remarkable balance between scientific precision and artistic beauty.",
      achievements: "Key Achievements",
      achievementsList: [
        "Translated Tolstoy's 'God Sees the Truth but Waits' to Kurdish",
        "Pioneer translator at KurdSubtitle (Infested, Imaginary films)",
        "Founder & Owner of Crown Root Import Company",
        "Creator of Dyar Bakr Dictionary",
        "Expert Graphic Designer & SketchUp Specialist",
        "Former Chief Financial Officer (CFO)",
        "Digital Marketing Agency Leader",
        "English Language Student at Salahaddin University"
      ]
    },
    ku: {
      title: "دەربارەی دامەزرێنەر",
      name: "دیار بەکر کاکۆ",
      born: "لەدایکبووی ٢٠٠٤، هەولێر",
      bio: "دیار بەکر کاکۆ (لەدایکبووی ٢٠٠٤، هەولێر)؛ نووسەر، وەرگێڕ و خاوەنکارێکی فرەبەهرەیە کە توانیویەتی لە تەمەنێکی زوودا مۆدێلێکی مۆدێرن لە سەرکردایەتی و داهێنان لە کوردستاندا بەرجەستە بکات. وەک خوێندکارێکی لێهاتووی زمانی ئینگلیزی لە زانکۆی سەڵاحەدین، دیار بە بلیمەتییەکی ناوازە شاکارە ئەدەبییەکەی لیۆ تۆلستۆی «خودا ڕاستی دەبینێت بەڵام چاوەڕێ دەکات»ی وەرگێڕاوەتە سەر زمانی کوردی و لە جیهانی سینەماشدا وەک وەرگێڕێکی دیاری فیلمە جیهانییەکان لە سەکۆی «کوردسەبتایتڵ» (بۆ فیلمەکانی وەک Infested و Imaginary) دەناسرێت.",
      business: "دیار لە کایەی بازرگانی و تەکنەلۆژیادا هێزێکی بڕیاردەرە؛ ئەو دامەزرێنەر و خاوەنی کۆمپانیا و «کۆگای کڕاون ڕۆت - Crown Root»ە بۆ کڕین و هاوردەکردنی کاڵا لە دەرەوەی وڵات، هەروەها داهێنەری «فەرهەنگی دیار بەکر»ە کە سەرچاوەیەکی مەعریفیی دەوڵەمەندە بۆ زمان و ئەدەبی کوردی. ئەم گەنجە داهێنەرە کە خاوەنی «براندی دیار بەکر» و گرافیک دیزاینەرێکی دەستڕەنگین و پسپۆڕێکی باوەڕپێکراوی SketchUp-ە، بە پشتبەستن بەو بناغە پۆڵایینەی لە ئەزموونی وەک بەڕێوەبەری پێشووی دارایی (CFO) بەدەستی هێناوە، توانیویەتی بە دیدگایەکی ستراتیژییەوە سەرکردایەتی ئاژانسێکی مارکێتینگی دیجیتاڵی بکات و هاوسەنگییەکی دەگمەن لە نێوان وردبینی زانستی و جوانیی هونەریدا دروست بکات.",
      achievements: "دەستکەوتە سەرەکییەکان",
      achievementsList: [
        "وەرگێڕانی «خودا ڕاستی دەبینێت بەڵام چاوەڕێ دەکات»ی تۆلستۆی بۆ کوردی",
        "وەرگێڕی پێشەنگ لە کوردسەبتایتڵ (فیلمەکانی Infested و Imaginary)",
        "دامەزرێنەر و خاوەنی کۆمپانیای کڕاون ڕۆت",
        "داهێنەری فەرهەنگی دیار بەکر",
        "پسپۆڕی گرافیک دیزاین و SketchUp",
        "بەڕێوەبەری پێشووی دارایی (CFO)",
        "سەرۆکی ئاژانسی مارکێتینگی دیجیتاڵ",
        "خوێندکاری زمانی ئینگلیزی لە زانکۆی سەڵاحەدین"
      ]
    }
  };

  const lang = content[language];
  const isKurdish = language === 'ku';

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 bg-gradient-to-br from-[#0a1929] via-[#1a237e] to-[#0a1929] z-50 overflow-y-auto"
    >
      {/* Back button */}
      <motion.button
        initial={{ x: -50, opacity: 0 }}
        animate={{ x: 0, opacity: 1 }}
        transition={{ delay: 0.2 }}
        onClick={onClose}
        className="fixed top-6 left-6 z-10 flex items-center gap-2 px-6 py-3 bg-[#FFD700] text-[#0a1929] rounded-xl font-semibold hover:bg-[#FFC700] transition-all shadow-lg"
      >
        <ArrowLeft className="size-5" />
        {isKurdish ? 'گەڕانەوە' : 'Back'}
      </motion.button>

      <div className="max-w-5xl mx-auto px-4 py-20">
        {/* Header */}
        <motion.div
          initial={{ y: 50, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.3 }}
          className={`text-center mb-12 ${isKurdish ? 'kurdish-text' : ''}`}
        >
          <h1 className="text-5xl md:text-6xl font-bold text-[#FFD700] mb-4">
            {lang.title}
          </h1>
          <div className="h-1 w-32 bg-gradient-to-r from-transparent via-[#FFD700] to-transparent mx-auto mb-6" />
          <h2 className="text-3xl md:text-4xl text-white font-semibold mb-2">
            {lang.name}
          </h2>
          <p className="text-xl text-[#B8860B]">{lang.born}</p>
        </motion.div>

        {/* Biography */}
        <motion.div
          initial={{ y: 50, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.5 }}
          className="mb-12"
        >
          <div className="bg-white/5 backdrop-blur-md rounded-2xl p-8 border border-[#FFD700]/20 shadow-2xl">
            <p className={`text-lg text-white/90 leading-relaxed mb-6 ${isKurdish ? 'kurdish-text text-xl' : ''}`}>
              {lang.bio}
            </p>
            <p className={`text-lg text-white/90 leading-relaxed ${isKurdish ? 'kurdish-text text-xl' : ''}`}>
              {lang.business}
            </p>
          </div>
        </motion.div>

        {/* Achievements */}
        <motion.div
          initial={{ y: 50, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.7 }}
        >
          <h3 className={`text-3xl font-bold text-[#FFD700] mb-6 text-center ${isKurdish ? 'kurdish-text' : ''}`}>
            {lang.achievements}
          </h3>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {lang.achievementsList.map((achievement, index) => (
              <motion.div
                key={index}
                initial={{ x: index % 2 === 0 ? -50 : 50, opacity: 0 }}
                animate={{ x: 0, opacity: 1 }}
                transition={{ delay: 0.9 + index * 0.1 }}
                className="bg-white/5 backdrop-blur-md rounded-xl p-6 border border-[#FFD700]/20 hover:border-[#FFD700]/50 transition-all shadow-lg hover:shadow-xl group"
              >
                <div className="flex items-start gap-4">
                  <div className="flex-shrink-0 w-10 h-10 bg-gradient-to-br from-[#FFD700] to-[#FFC700] rounded-full flex items-center justify-center group-hover:scale-110 transition-transform">
                    {index === 0 && <Languages className="size-5 text-[#0a1929]" />}
                    {index === 1 && <Film className="size-5 text-[#0a1929]" />}
                    {index === 2 && <Building2 className="size-5 text-[#0a1929]" />}
                    {index === 3 && <Award className="size-5 text-[#0a1929]" />}
                    {index === 4 && <Award className="size-5 text-[#0a1929]" />}
                    {index === 5 && <Briefcase className="size-5 text-[#0a1929]" />}
                    {index === 6 && <Briefcase className="size-5 text-[#0a1929]" />}
                    {index === 7 && <GraduationCap className="size-5 text-[#0a1929]" />}
                  </div>
                  <p className={`text-white/90 flex-1 ${isKurdish ? 'kurdish-text text-lg' : ''}`}>
                    {achievement}
                  </p>
                </div>
              </motion.div>
            ))}
          </div>
        </motion.div>

        {/* Footer */}
        <motion.div
          initial={{ y: 50, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 1.5 }}
          className="mt-12 text-center"
        >
          <div className="inline-block bg-gradient-to-r from-[#FFD700] to-[#FFC700] text-[#0a1929] px-8 py-4 rounded-full font-bold text-xl shadow-2xl">
            {isKurdish ? 'براندی دیار بەکر - ٢٠٢٦' : 'Dyar Bakr Brand - 2026'}
          </div>
        </motion.div>
      </div>
    </motion.div>
  );
}
