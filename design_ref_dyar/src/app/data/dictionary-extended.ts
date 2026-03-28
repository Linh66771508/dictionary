export interface DictionaryWord {
  id: number;
  english: string;
  kurdish: string;
  pronunciation: string;
  category: string;
  synonyms: string[];
  antonyms: string[];
  exampleSentence: string;
  exampleTranslation: string;
  imageQuery: string;
}

// Extended dictionary with 200 additional common English words
export const additionalWords: DictionaryWord[] = [
  {
    id: 201,
    english: "The",
    kurdish: "ئەو",
    pronunciation: "aw",
    category: "common",
    synonyms: [],
    antonyms: [],
    exampleSentence: "The book is on the table.",
    exampleTranslation: "کتێبەکە لەسەر مێزەکەیە.",
    imageQuery: "article grammar english"
  },
  {
    id: 202,
    english: "Be",
    kurdish: "بوون",
    pronunciation: "bun",
    category: "common",
    synonyms: ["Exist", "Live"],
    antonyms: [],
    exampleSentence: "I want to be successful.",
    exampleTranslation: "دەمەوێت سەرکەوتوو بم.",
    imageQuery: "existence being concept"
  },
  {
    id: 203,
    english: "Have",
    kurdish: "هەبوون",
    pronunciation: "habun",
    category: "common",
    synonyms: ["Possess", "Own"],
    antonyms: ["Lack"],
    exampleSentence: "I have a new phone.",
    exampleTranslation: "من تەلەفۆنێکی نوێم هەیە.",
    imageQuery: "possession owning phone"
  },
  {
    id: 204,
    english: "Do",
    kurdish: "کردن",
    pronunciation: "kirdn",
    category: "common",
    synonyms: ["Perform", "Execute"],
    antonyms: [],
    exampleSentence: "What do you do for work?",
    exampleTranslation: "بۆ کار چی دەکەیت؟",
    imageQuery: "action doing task"
  },
  {
    id: 205,
    english: "Say",
    kurdish: "وتن",
    pronunciation: "wtin",
    category: "common",
    synonyms: ["Speak", "Tell"],
    antonyms: [],
    exampleSentence: "What did you say?",
    exampleTranslation: "چیت وت؟",
    imageQuery: "speaking saying communication"
  },
  {
    id: 206,
    english: "Get",
    kurdish: "وەرگرتن",
    pronunciation: "wargrtin",
    category: "common",
    synonyms: ["Obtain", "Receive"],
    antonyms: ["Give"],
    exampleSentence: "I need to get some rest.",
    exampleTranslation: "پێویستە هەندێک پشوو بکەم.",
    imageQuery: "receiving getting obtaining"
  },
  {
    id: 207,
    english: "Make",
    kurdish: "دروستکردن",
    pronunciation: "drustkrdn",
    category: "common",
    synonyms: ["Create", "Build"],
    antonyms: ["Destroy"],
    exampleSentence: "Let's make dinner together.",
    exampleTranslation: "با پێکەوە نانی ئێوارە دروست بکەین.",
    imageQuery: "making creating crafting"
  },
  {
    id: 208,
    english: "Go",
    kurdish: "ڕۆیشتن",
    pronunciation: "royshtin",
    category: "common",
    synonyms: ["Move", "Travel"],
    antonyms: ["Come", "Stay"],
    exampleSentence: "Let's go to the park.",
    exampleTranslation: "با بچینە پارکەکە.",
    imageQuery: "going walking movement"
  },
  {
    id: 209,
    english: "Know",
    kurdish: "زانین",
    pronunciation: "zanin",
    category: "common",
    synonyms: ["Understand", "Comprehend"],
    antonyms: ["Unknown"],
    exampleSentence: "I know the answer.",
    exampleTranslation: "من وەڵامەکە دەزانم.",
    imageQuery: "knowledge knowing understanding"
  },
  {
    id: 210,
    english: "Take",
    kurdish: "وەرگرتن",
    pronunciation: "wargrtin",
    category: "common",
    synonyms: ["Grab", "Seize"],
    antonyms: ["Give"],
    exampleSentence: "Take this book with you.",
    exampleTranslation: "ئەم کتێبە لەگەڵ خۆت ببە.",
    imageQuery: "taking holding grasping"
  },
  {
    id: 211,
    english: "See",
    kurdish: "بینین",
    pronunciation: "binin",
    category: "common",
    synonyms: ["View", "Watch"],
    antonyms: [],
    exampleSentence: "I can see the mountains.",
    exampleTranslation: "من دەتوانم چیاکان ببینم.",
    imageQuery: "seeing vision eye viewing"
  },
  {
    id: 212,
    english: "Come",
    kurdish: "هاتن",
    pronunciation: "hatin",
    category: "common",
    synonyms: ["Arrive", "Approach"],
    antonyms: ["Go"],
    exampleSentence: "Come here, please.",
    exampleTranslation: "تکایە وەرە ئێرە.",
    imageQuery: "coming arriving approaching"
  },
  {
    id: 213,
    english: "Think",
    kurdish: "بیرکردنەوە",
    pronunciation: "birkrdnawa",
    category: "common",
    synonyms: ["Consider", "Contemplate"],
    antonyms: [],
    exampleSentence: "I think you are right.",
    exampleTranslation: "من پێموایە تۆ ڕاستی.",
    imageQuery: "thinking contemplation thought"
  },
  {
    id: 214,
    english: "Look",
    kurdish: "سەیرکردن",
    pronunciation: "sayrkrdn",
    category: "common",
    synonyms: ["Watch", "Observe"],
    antonyms: [],
    exampleSentence: "Look at this beautiful view!",
    exampleTranslation: "سەیری ئەم دیمەنە جوانە بکە!",
    imageQuery: "looking observing watching"
  },
  {
    id: 215,
    english: "Want",
    kurdish: "ویستن",
    pronunciation: "wistin",
    category: "common",
    synonyms: ["Desire", "Wish"],
    antonyms: [],
    exampleSentence: "I want to learn Kurdish.",
    exampleTranslation: "دەمەوێت کوردی فێربم.",
    imageQuery: "wanting desire wishing"
  },
  {
    id: 216,
    english: "Give",
    kurdish: "دان",
    pronunciation: "dan",
    category: "common",
    synonyms: ["Provide", "Offer"],
    antonyms: ["Take"],
    exampleSentence: "Give me your hand.",
    exampleTranslation: "دەستت بدەرێ.",
    imageQuery: "giving sharing generosity"
  },
  {
    id: 217,
    english: "Use",
    kurdish: "بەکارهێنان",
    pronunciation: "bakarhênan",
    category: "common",
    synonyms: ["Utilize", "Employ"],
    antonyms: [],
    exampleSentence: "Use your time wisely.",
    exampleTranslation: "کاتەکەت بە دانایی بەکاربهێنە.",
    imageQuery: "using tools utilizing"
  },
  {
    id: 218,
    english: "Find",
    kurdish: "دۆزینەوە",
    pronunciation: "dozinawa",
    category: "common",
    synonyms: ["Discover", "Locate"],
    antonyms: ["Lose"],
    exampleSentence: "I can't find my keys.",
    exampleTranslation: "ناتوانم کلیلەکانم بدۆزمەوە.",
    imageQuery: "finding searching discovery"
  },
  {
    id: 219,
    english: "Tell",
    kurdish: "پێگوتن",
    pronunciation: "pêgutin",
    category: "common",
    synonyms: ["Inform", "Narrate"],
    antonyms: [],
    exampleSentence: "Tell me your story.",
    exampleTranslation: "چیرۆکەکەت بۆ بگێڕەوە.",
    imageQuery: "telling storytelling communication"
  },
  {
    id: 220,
    english: "Ask",
    kurdish: "پرسین",
    pronunciation: "pirsin",
    category: "common",
    synonyms: ["Inquire", "Question"],
    antonyms: ["Answer"],
    exampleSentence: "Don't be afraid to ask questions.",
    exampleTranslation: "مەترسە لە پرسیار کردن.",
    imageQuery: "asking question inquiry"
  }
];
