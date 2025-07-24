import 'package:flutter/material.dart';

class OemBusinessIntro extends StatelessWidget {
  const OemBusinessIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('业务联系,下载fChat 添加客服:6498124'),
          const SizedBox(height: 10,),
          _buildPlanCard(
            title: "App OEM",
            platforms: "平台: iOS / Android",
            description: "共享FChat服务器，遵守UGC与运营规范，可上架 App Store / Google Play。",
            price: "费用: \$20,000 USD",
            monthly: "每月服务器与维护费: \$1,000 USD",
          ),
          const SizedBox(height: 12),
          _buildPlanCard(
            title: "全平台 OEM",
            platforms: "平台: iOS / Android / Windows / macOS",
            description: "共享FChat服务器，支持移动与桌面端，全平台统一体验。",
            price: "费用: \$30,000 USD",
            monthly: "每月服务器与维护费: \$1,500 USD",
          ),
          const SizedBox(height: 12),
          _buildPlanCard(
            title: "全 OEM（独立部署）",
            platforms: "平台: 全平台",
            description: "包含App与服务器独立部署，完全自主品牌运营，支持上架与自托管。",
            price: "费用: \$100,000 USD",
            monthly: "每月维护费: \$1,000 USD",
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String platforms,
    required String description,
    required String price,
    required String monthly,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(platforms, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 8),
            Text(price, style: const TextStyle(color: Colors.green)),
            Text(monthly, style: const TextStyle(color: Colors.orange)),
          ],
        ),
      ),
    );
  }
}
