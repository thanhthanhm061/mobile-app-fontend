
import 'package:flutter/material.dart';

class CredentialsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0E27),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chứng Chỉ',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildCredentialCard(
                    'Bằng Đại Học',
                    'Đại học Bách Khoa',
                    'Công nghệ thông tin',
                    Icons.school,
                    Color(0xFF3B82F6),
                  ),
                  _buildCredentialCard(
                    'Chứng Chỉ Nghề Nghiệp',
                    'Blockchain Institute',
                    'Blockchain Developer',
                    Icons.workspace_premium,
                    Color(0xFF10B981),
                  ),
                  _buildCredentialCard(
                    'CMND/CCCD',
                    'Cục Cảnh Sát',
                    'Số: 001234567890',
                    Icons.credit_card,
                    Color(0xFFF59E0B),
                  ),
                  _buildCredentialCard(
                    'Giấy Phép Lái Xe',
                    'Sở GTVT',
                    'Hạng B2',
                    Icons.car_rental,
                    Color(0xFF8B5CF6),
                  ),
                  _buildCredentialCard(
                    'Bảo Hiểm Y Tế',
                    'Bảo Hiểm Xã Hội',
                    'Mã: BH123456789',
                    Icons.medical_services,
                    Color(0xFFEF4444),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialCard(
    String title,
    String issuer,
    String details,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  issuer,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  details,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withOpacity(0.3),
            size: 16,
          ),
        ],
      ),
    );
  }
}