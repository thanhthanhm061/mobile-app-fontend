import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ssi_app/services/web3_service.dart';


class CredentialsScreen extends StatefulWidget {
  @override
  _CredentialsScreenState createState() => _CredentialsScreenState();
}

class _CredentialsScreenState extends State<CredentialsScreen> {
  final _web3Service = Web3Service();
  List<Map<String, dynamic>> _credentials = [];
  bool _isLoading = true;
  String _address = '';

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  @override
  void dispose() {
    _web3Service.dispose();
    super.dispose();
  }

  Future<void> _loadCredentials() async {
    try {
      final address = await _web3Service.loadWallet();
      if (address != null) {
        _address = address;
        final vcs = await _web3Service.getVCs(address);
        setState(() {
          _credentials = vcs;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading credentials: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  IconData _getIconForCredential(int index) {
    final icons = [
      Icons.school,
      Icons.workspace_premium,
      Icons.credit_card,
      Icons.car_rental,
      Icons.medical_services,
      Icons.card_membership,
      Icons.verified,
      Icons.badge,
    ];
    return icons[index % icons.length];
  }

  Color _getColorForCredential(int index) {
    final colors = [
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
      Color(0xFFEF4444),
      Color(0xFF06B6D4),
      Color(0xFFEC4899),
      Color(0xFF84CC16),
    ];
    return colors[index % colors.length];
  }

  String _getCredentialTitle(int index) {
    final titles = [
      'Bằng Đại Học',
      'Chứng Chỉ Nghề Nghiệp',
      'CMND/CCCD',
      'Giấy Phép Lái Xe',
      'Bảo Hiểm Y Tế',
      'Thẻ Thành Viên',
      'Chứng Nhận',
      'Huy Hiệu',
    ];
    return titles[index % titles.length];
  }

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
                    child: InkWell(
                      onTap: _showAddCredentialDialog,
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                          SizedBox(height: 16),
                          Text(
                            'Đang tải chứng chỉ...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  : _credentials.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_open,
                                size: 80,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Chưa có chứng chỉ',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Nhấn nút + để thêm chứng chỉ mới',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadCredentials,
                          color: Color(0xFF8B5CF6),
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _credentials.length,
                            itemBuilder: (context, index) {
                              final credential = _credentials[index];
                              return _buildCredentialCard(
                                _getCredentialTitle(index),
                                credential['issuer'] ?? 'Unknown',
                                'Hash: ${credential['hashCredential'].substring(0, 10)}...',
                                credential['uri'] ?? '',
                                _getIconForCredential(index),
                                _getColorForCredential(index),
                                credential['valid'] ?? false,
                                index,
                              );
                            },
                          ),
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
    String uri,
    IconData icon,
    Color color,
    bool isValid,
    int index,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isValid ? color.withOpacity(0.3) : Colors.red.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () => _showCredentialDetails(index),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isValid
                              ? Color(0xFF10B981).withOpacity(0.2)
                              : Color(0xFFEF4444).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isValid ? 'Valid' : 'Revoked',
                          style: TextStyle(
                            color: isValid ? Color(0xFF10B981) : Color(0xFFEF4444),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Issuer: ${issuer.substring(0, 10)}...',
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
      ),
    );
  }

  void _showCredentialDetails(int index) {
    final credential = _credentials[index];
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getColorForCredential(index).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForCredential(index),
                      color: _getColorForCredential(index),
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCredentialTitle(index),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: credential['valid']
                                ? Color(0xFF10B981).withOpacity(0.2)
                                : Color(0xFFEF4444).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            credential['valid'] ? 'Valid' : 'Revoked',
                            style: TextStyle(
                              color: credential['valid']
                                  ? Color(0xFF10B981)
                                  : Color(0xFFEF4444),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              _buildDetailRow('Index', credential['index'].toString()),
              _buildDetailRow('Issuer', credential['issuer']),
              _buildDetailRow('Hash', credential['hashCredential']),
              _buildDetailRow('URI', credential['uri']),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: credential['hashCredential']),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã sao chép hash'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      },
                      icon: Icon(Icons.copy),
                      label: Text('Copy Hash'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6366F1),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  if (credential['valid'])
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _revokeCredential(index);
                        },
                        icon: Icon(Icons.block),
                        label: Text('Revoke'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFEF4444),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
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
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontFamily: 'Courier',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showAddCredentialDialog() {
    final uriController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1F3A),
        title: Text('Phát hành VC mới', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: uriController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'VC URI (IPFS/URL)',
                hintText: 'ipfs://QmXxx... hoặc https://...',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
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
              if (uriController.text.isNotEmpty) {
                Navigator.pop(context);
                _issueVC(uriController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8B5CF6),
            ),
            child: Text('Phát hành'),
          ),
        ],
      ),
    );
  }

  Future<void> _issueVC(String uri) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
        ),
      );

      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final hashData = '0x' + (_address + timestamp)
          .replaceAll('0x', '')
          .padRight(64, '0')
          .substring(0, 64);

      final txHash = await _web3Service.issueVC(_address, hashData, uri);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('VC đã được phát hành! TX: ${txHash.substring(0, 10)}...'),
          backgroundColor: Color(0xFF10B981),
        ),
      );

      _loadCredentials();
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

  Future<void> _revokeCredential(int index) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
        ),
      );

      final txHash = await _web3Service.revokeVC(_address, index);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('VC đã bị thu hồi! TX: ${txHash.substring(0, 10)}...'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );

      _loadCredentials();
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