import 'package:flutter/material.dart';
import '../models/joker_model.dart';

class HowToPlayDialog extends StatelessWidget {
  const HowToPlayDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const HowToPlayDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0D1B2A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5),
            ],
          ),
          child: Column(
            children: [
              // Handle for dragging
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.tips_and_updates_rounded, color: Color(0xFFFFD700), size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Nasıl Oynanır?',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF1E2D40), thickness: 1),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildSectionHeader('🎯 Temel Kurallar'),
                    _buildInfoCard(
                      'Harfleri Birleştirin',
                      'Harfleri sürükleyerek veya dokunarak kelime oluşturun. Geçerli bir kelime için en az 3 harf kullanmalısınız. Daha uzun kelimeler daha yüksek puan verir!',
                      Icons.touch_app_rounded,
                    ),
                    const SizedBox(height: 20),
                    
                    _buildSectionHeader('🕹️ Zorluk Seçimi'),
                    _buildInfoCard(
                      'Grid ve Hamle Sayısı',
                      'Büyük grid boyutu, daha fazla harf sunduğu için kelime bulmayı kolaylaştırır. Ancak seçtiğiniz hamle sayısı ne kadar az ise oyun o kadar stratejik ve zorlayıcı hale gelir.',
                      Icons.grid_on_rounded,
                    ),
                    const SizedBox(height: 20),
                    
                    _buildSectionHeader('🔥 Kombo & Özel Güçler'),
                    _buildInfoCard(
                      'Gizli Kelimeler',
                      'Bulduğunuz kelimenin içinde başka geçerli kelimeler geçiyorsa ekstra Kombo Puanı kazanırsınız.',
                      Icons.local_fire_department_rounded,
                    ),
                    _buildInfoCard(
                      'Uzun Kelime Güçleri',
                      '4 harfli kelimeler Satır patlatan güce, 5 harfliler Alan bombasına, 6 harfliler Sütun temizleyiciye, 7 ve üstü harfliler ise Mega bombaya dönüşür!',
                      Icons.flash_on_rounded,
                    ),
                    const SizedBox(height: 20),
                    
                    _buildSectionHeader('💎 Jokerler (Bonuslar)'),
                    ...JokerModel.all.map((joker) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111820),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1E2D40)),
                        ),
                        child: Row(
                          children: [
                            Text(joker.icon, style: const TextStyle(fontSize: 32)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    joker.name,
                                    style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    joker.description,
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    )),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard(String title, String desc, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2436),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A4060)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90D9).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF4A90D9), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 6),
                Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
