import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ssi_app/services/web3_service.dart';
import 'package:web3dart/web3dart.dart';


class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _web3Service = Web3Service();
  String _address = 'Loading...';
  String _balance = '0';
  int _vcCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  @override
  void dispose() {
    _web3Service.dispose();
    super.dispose();
  }

  Future<void> _loadWalletData() async {
    try {
      // Load wallet address
      final address = await _web3Service.loadWallet();
      
      if (address != null) {
        // Get balance
        final balance = await _web3Service.getBalance();
        
        // Get VC count (assuming orgID is the address)
        try {
          final vcs = await _web3Service.getVCs(address);
          setState(() {
            _address = address;
            _balance = balance.getValueInUnit(EtherUnit.ether).toStringAsFixed(4);
            _vcCount = vcs.length;
            _isLoading = false;
          });
        } catch (e) {
          // DID might not be registered yet
          setState(() {
            _address = address;
            _balance = balance.getValueInUnit(EtherUnit.ether).toStringAsFixed(4);
            _vcCount = 0;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading wallet data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _shortenAddress(String address) {
    if (address.length < 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0E27),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                    SizedBox(height: 16),
                    Text(
                      'Đang tải dữ liệu...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadWalletData,
                color: Color(0xFF8B5CF6),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Xin chào,',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Người dùng',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF6366F1).withOpacity(0.3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ví Danh Tính',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.copy, color: Colors.white, size: 18),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: _address));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Đã sao chép địa chỉ'),
                                            backgroundColor: Color(0xFF10B981),
                                          ),
                                        );
                                      },
                                    ),
                                    Icon(Icons.more_horiz, color: Colors.white),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Text(
                              _shortenAddress(_address),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.verified, color: Colors.white, size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'Sepolia Testnet',
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ],
                                ),
                                Text(
                                  '$_balance ETH',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      Text(
                        'Thống kê',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Chứng chỉ',
                              _vcCount.toString(),
                              Icons.card_membership,
                              Color(0xFF3B82F6),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Đã xác minh',
                              _vcCount.toString(),
                              Icons.verified,
                              Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Số dư',
                              '$_balance ETH',
                              Icons.account_balance_wallet,
                              Color(0xFFF59E0B),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildActionCard(
                              'Đăng ký DID',
                              Icons.person_add,
                              Color(0xFF8B5CF6),
                              () => _showRegisterDIDDialog(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      Text(
                        'Hành động nhanh',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildQuickAction(
                        'Phát hành chứng chỉ',
                        'Tạo và phát hành VC mới',
                        Icons.add_card,
                        Color(0xFF3B82F6),
                        () => _showIssueVCDialog(),
                      ),
                      _buildQuickAction(
                        'Xem chứng chỉ',
                        'Danh sách chứng chỉ của bạn',
                        Icons.list_alt,
                        Color(0xFF10B981),
                        () {
                          // Navigate to credentials tab
                          DefaultTabController.of(context).animateTo(1);
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.3),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRegisterDIDDialog() {
    final orgIDController = TextEditingController(text: _address);
    final uriController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1F3A),
        title: Text('Đăng ký DID', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: orgIDController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Organization ID',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: uriController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'DID URI (IPFS/URL)',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _registerDID(orgIDController.text, uriController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8B5CF6),
            ),
            child: Text('Đăng ký'),
          ),
        ],
      ),
    );
  }

  Future<void> _registerDID(String orgID, String uri) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
        ),
      );

      // Create hash from orgID
      final hashData = '0x' + orgID.replaceAll('0x', '').padRight(64, '0').substring(0, 64);
      
      final txHash = await _web3Service.registerDID(orgID, hashData, uri);
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('DID đã được đăng ký! TX: ${txHash.substring(0, 10)}...'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      
      _loadWalletData();
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  void _showIssueVCDialog() {
    final orgIDController = TextEditingController(text: _address);
    final uriController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1F3A),
        title: Text('Phát hành VC', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: orgIDController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Organization ID',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: uriController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'VC URI (IPFS/URL)',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _issueVC(orgIDController.text, uriController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3B82F6),
            ),
            child: Text('Phát hành'),
          ),
        ],
      ),
    );
  }

  Future<void> _issueVC(String orgID, String uri) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
        ),
      );

      // Create hash from timestamp and orgID
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final hashData = '0x' + (orgID + timestamp).replaceAll('0x', '').padRight(64, '0').substring(0, 64);
      
      final txHash = await _web3Service.issueVC(orgID, hashData, uri);
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('VC đã được phát hành! TX: ${txHash.substring(0, 10)}...'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      
      _loadWalletData();
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }
}