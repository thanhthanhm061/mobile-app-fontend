import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ssi_app/screen/LoginScreen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssi_app/services/web3_service.dart';
import 'package:web3dart/web3dart.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _web3Service = Web3Service();
  String _address = 'Loading...';
  String _balance = '0';
  String _mnemonic = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _web3Service.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    try {
      final address = await _web3Service.loadWallet();
      if (address != null) {
        final balance = await _web3Service.getBalance();
        
        // Load mnemonic từ SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final mnemonic = prefs.getString('mnemonic') ?? '';
        
        setState(() {
          _address = address;
          _balance = balance.getValueInUnit(EtherUnit.ether).toStringAsFixed(4);
          _mnemonic = mnemonic;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _shortenAddress(String address) {
    if (address.length < 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
  }

  Future<void> _logout() async {
    // Hiển thị confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1F3A),
        title: Text('Xác nhận đăng xuất', style: TextStyle(color: Colors.white)),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất?\n\nĐảm bảo bạn đã sao lưu Private Key hoặc Mnemonic.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFEF4444)),
            child: Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Xóa dữ liệu ví
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Navigate to login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showWalletInfo() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet, color: Color(0xFF8B5CF6), size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Thông tin ví',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                _buildInfoRow('Địa chỉ ví', _address, canCopy: true),
                _buildInfoRow('Số dư', '$_balance ETH'),
                _buildInfoRow('Mạng', 'Sepolia Testnet'),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFFBBF24).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFFBBF24)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Color(0xFFFBBF24), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Không chia sẻ thông tin này với bất kỳ ai!',
                          style: TextStyle(
                            color: Color(0xFFFBBF24),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B5CF6),
                    minimumSize: Size(double.infinity, 48),
                  ),
                  child: Text('Đóng'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBackupKeys() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.vpn_key, color: Color(0xFFEF4444), size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Sao lưu khóa',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFEF4444)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.security, color: Color(0xFFEF4444), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'QUAN TRỌNG: Lưu thông tin này ở nơi an toàn!',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                if (_mnemonic.isNotEmpty) ...[
                  Text(
                    'Cụm từ khôi phục (12 từ):',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _mnemonic,
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Courier',
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, color: Color(0xFF8B5CF6)),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _mnemonic));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã sao chép mnemonic'),
                                backgroundColor: Color(0xFF10B981),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ] else ...[
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Mnemonic không khả dụng.\nBạn có thể đã import ví bằng Private Key.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 16),
                ],
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B5CF6),
                    minimumSize: Size(double.infinity, 48),
                  ),
                  child: Text('Đóng'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool canCopy = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  value.length > 42 ? '${value.substring(0, 10)}...${value.substring(value.length - 10)}' : value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: value.startsWith('0x') ? 'Courier' : null,
                  ),
                ),
              ),
              if (canCopy)
                IconButton(
                  icon: Icon(Icons.copy, color: Color(0xFF8B5CF6), size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã sao chép $label'),
                        backgroundColor: Color(0xFF10B981),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0E27),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
              )
            : RefreshIndicator(
                onRefresh: _loadProfileData,
                color: Color(0xFF8B5CF6),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Hồ Sơ',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 32),
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Color(0xFF1A1F3A),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person, size: 60, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        _shortenAddress(_address),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Courier',
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF10B981).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFF10B981)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.account_balance_wallet, color: Color(0xFF10B981), size: 16),
                            SizedBox(width: 6),
                            Text(
                              '$_balance ETH',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      _buildProfileOption(
                        Icons.account_circle_outlined,
                        'Thông tin ví',
                        onTap: _showWalletInfo,
                      ),
                      _buildProfileOption(
                        Icons.vpn_key_outlined,
                        'Sao lưu khóa',
                        onTap: _showBackupKeys,
                      ),
                      _buildProfileOption(
                        Icons.security_outlined,
                        'Bảo mật',
                        badge: 'Soon',
                      ),
                      _buildProfileOption(
                        Icons.history_outlined,
                        'Lịch sử giao dịch',
                        badge: 'Soon',
                      ),
                      _buildProfileOption(
                        Icons.settings_outlined,
                        'Cài đặt',
                        badge: 'Soon',
                      ),
                      _buildProfileOption(
                        Icons.help_outline,
                        'Trợ giúp',
                        badge: 'Soon',
                      ),
                      SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Color(0xFFEF4444), width: 1.5),
                        ),
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Đăng xuất',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfileOption(
    IconData icon,
    String title, {
    VoidCallback? onTap,
    String? badge,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF6366F1).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Color(0xFF8B5CF6), size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFFFBBF24).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: Color(0xFFFBBF24),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white.withOpacity(0.3),
            ),
          ],
        ),
        onTap: onTap ?? () {},
        enabled: onTap != null,
      ),
    );
  }
}