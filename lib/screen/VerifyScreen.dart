import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ssi_app/services/web3_service.dart';


class VerifyScreen extends StatefulWidget {
  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _web3Service = Web3Service();
  String _address = '';

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  @override
  void dispose() {
    _web3Service.dispose();
    super.dispose();
  }

  Future<void> _loadAddress() async {
    final address = await _web3Service.loadWallet();
    if (address != null) {
      setState(() {
        _address = address;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0E27),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Xác Minh',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF6366F1).withOpacity(0.3),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: _address.isNotEmpty
                              ? QrImageView(
                                  data: _address,
                                  version: QrVersions.auto,
                                  size: 200.0,
                                  backgroundColor: Colors.white,
                                  eyeStyle: QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: Color(0xFF6366F1),
                                  ),
                                  dataModuleStyle: QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: Color(0xFF1A1F3A),
                                  ),
                                )
                              : Container(
                                  width: 200,
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF6366F1),
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(height: 32),
                        Text(
                          'Mã QR của tôi',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Chia sẻ mã QR này để người khác có thể xác minh danh tính của bạn',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            _address.isNotEmpty
                                ? '${_address.substring(0, 6)}...${_address.substring(_address.length - 6)}'
                                : 'Loading...',
                            style: TextStyle(
                              color: Color(0xFF8B5CF6),
                              fontSize: 14,
                              fontFamily: 'Courier',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 40),
                        Container(
                          width: double.infinity,
                          height: 56,
                          margin: EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Color(0xFF8B5CF6),
                              width: 2,
                            ),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _showVerifyDialog,
                            icon: Icon(Icons.qr_code_scanner),
                            label: Text('Xác minh VC'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Color(0xFF8B5CF6),
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'hoặc',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          height: 56,
                          margin: EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF6366F1).withOpacity(0.4),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _showManualVerifyDialog,
                            icon: Icon(Icons.edit),
                            label: Text('Nhập thủ công'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVerifyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1F3A),
        title: Text('Quét QR', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: 80,
              color: Color(0xFF8B5CF6),
            ),
            SizedBox(height: 16),
            Text(
              'Chức năng quét QR sẽ được tích hợp trong phiên bản tiếp theo',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Hiện tại bạn có thể sử dụng chức năng "Nhập thủ công"',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng', style: TextStyle(color: Color(0xFF8B5CF6))),
          ),
        ],
      ),
    );
  }

  void _showManualVerifyDialog() {
    final orgIDController = TextEditingController();
    final indexController = TextEditingController();
    final hashController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1F3A),
        title: Text('Xác minh VC', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: orgIDController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Organization ID',
                  hintText: '0x...',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: indexController,
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'VC Index',
                  hintText: '0',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: hashController,
                style: TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Credential Hash',
                  hintText: '0x...',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (orgIDController.text.isNotEmpty &&
                  indexController.text.isNotEmpty &&
                  hashController.text.isNotEmpty) {
                Navigator.pop(context);
                _verifyVC(
                  orgIDController.text,
                  int.parse(indexController.text),
                  hashController.text,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8B5CF6),
            ),
            child: Text('Xác minh'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyVC(String orgID, int index, String hash) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
        ),
      );

      final isValid = await _web3Service.verifyVC(orgID, index, hash);

      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Color(0xFF1A1F3A),
          title: Row(
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.cancel,
                color: isValid ? Color(0xFF10B981) : Color(0xFFEF4444),
                size: 32,
              ),
              SizedBox(width: 12),
              Text(
                isValid ? 'Hợp lệ' : 'Không hợp lệ',
                style: TextStyle(
                  color: isValid ? Color(0xFF10B981) : Color(0xFFEF4444),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            isValid
                ? 'Chứng chỉ này đã được xác minh và còn hiệu lực'
                : 'Chứng chỉ này không hợp lệ hoặc đã bị thu hồi',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: isValid ? Color(0xFF10B981) : Color(0xFFEF4444),
              ),
              child: Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi xác minh: $e'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }
}