import { motion } from 'motion/react';
import logo from 'figma:asset/8f4b2013606a1f72cb143375103c1f61024f0609.png';

interface WelcomeSplashProps {
  onComplete: () => void;
}

export function WelcomeSplash({ onComplete }: WelcomeSplashProps) {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ duration: 0.5 }}
      className="fixed inset-0 bg-gradient-to-br from-[#0a1929] via-[#1a237e] to-[#0a1929] flex items-center justify-center z-50"
    >
      {/* Animated background particles */}
      <div className="absolute inset-0 overflow-hidden">
        {[...Array(20)].map((_, i) => (
          <motion.div
            key={i}
            className="absolute w-2 h-2 bg-[#FFD700] rounded-full"
            initial={{
              x: Math.random() * window.innerWidth,
              y: Math.random() * window.innerHeight,
              opacity: 0,
            }}
            animate={{
              y: [null, Math.random() * window.innerHeight],
              opacity: [0, 0.6, 0],
            }}
            transition={{
              duration: 3 + Math.random() * 2,
              repeat: Infinity,
              delay: Math.random() * 2,
            }}
          />
        ))}
      </div>

      <div className="relative z-10 text-center px-4">
        {/* Logo with animation */}
        <motion.div
          initial={{ scale: 0, rotate: -180 }}
          animate={{ scale: 1, rotate: 0 }}
          transition={{
            type: 'spring',
            stiffness: 200,
            damping: 15,
            duration: 1.2,
          }}
          className="mb-8"
        >
          <img
            src={logo}
            alt="Dyar Bakr Dictionary Logo"
            className="w-64 h-64 mx-auto object-contain drop-shadow-2xl"
          />
        </motion.div>

        {/* Title */}
        <motion.h1
          initial={{ y: 50, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.8, duration: 0.6 }}
          className="text-5xl md:text-6xl font-bold text-[#FFD700] mb-4 tracking-tight"
        >
          Dyar Bakr Dictionary
        </motion.h1>

        {/* Powered by text */}
        <motion.p
          initial={{ y: 30, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 1.2, duration: 0.6 }}
          className="text-xl md:text-2xl text-[#B8860B] font-medium mb-2"
        >
          Powered by
        </motion.p>

        <motion.p
          initial={{ y: 30, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 1.4, duration: 0.6 }}
          className="text-2xl md:text-3xl text-white font-semibold"
        >
          Dyar Bakr Kako
        </motion.p>

        <motion.p
          initial={{ y: 30, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 1.6, duration: 0.6 }}
          className="text-lg text-[#FFD700] mt-2"
        >
          © 2026
        </motion.p>

        {/* Loading bar */}
        <motion.div
          initial={{ scaleX: 0 }}
          animate={{ scaleX: 1 }}
          transition={{ delay: 1.8, duration: 1.5 }}
          onAnimationComplete={onComplete}
          className="mt-12 h-1 w-64 mx-auto bg-gradient-to-r from-[#FFD700] via-white to-[#FFD700] rounded-full"
        />
      </div>
    </motion.div>
  );
}
