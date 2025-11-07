import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bip39/bip39.dart' as bip39;

class Web3Service {
  static const String CONTRACT_ADDRESS = '0x002F3e4e86E1eFC79C628d81B9942bb423ecFE35';
  static const String RPC_URL = 'https://eth-sepolia.g.alchemy.com/v2/your_alchemy_key';
  
  late Web3Client _client;
  late DeployedContract _contract;
  late Credentials _credentials;
  
  // Contract ABI - lấy từ file build của Hardhat
  static const String CONTRACT_ABI = '''
  [
    {
      "inputs": [{"internalType": "string","name": "orgID","type": "string"}],
      "name": "deactivateDID",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "string","name": "orgID","type": "string"},{"internalType": "address","name": "issuer","type": "address"}],
      "name": "authorizeIssuer",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "string","name": "orgID","type": "string"},{"internalType": "bytes32","name": "hashData","type": "bytes32"},{"internalType": "string","name": "uri","type": "string"}],
      "name": "registerDID",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "string","name": "orgID","type": "string"},{"internalType": "bytes32","name": "hashCredential","type": "bytes32"},{"internalType": "string","name": "uri","type": "string"}],
      "name": "issueVC",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "string","name": "orgID","type": "string"},{"internalType": "uint256","name": "index","type": "uint256"}],
      "name": "revokeVC",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "string","name": "orgID","type": "string"}],
      "name": "dids",
      "outputs": [{"internalType": "address","name": "owner","type": "address"},{"internalType": "bytes32","name": "hashData","type": "bytes32"},{"internalType": "string","name": "uri","type": "string"},{"internalType": "bool","name": "active","type": "bool"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "string","name": "orgID","type": "string"},{"internalType": "uint256","name": "index","type": "uint256"}],
      "name": "getVC",
      "outputs": [{"internalType": "bytes32","name": "hashCredential","type": "bytes32"},{"internalType": "string","name": "uri","type": "string"},{"internalType": "address","name": "issuer","type": "address"},{"internalType": "bool","name": "valid","type": "bool"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "string","name": "orgID","type": "string"}],
      "name": "getVCLength",
      "outputs": [{"internalType": "uint256","name": "","type": "uint256"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "string","name": "orgID","type": "string"},{"internalType": "uint256","name": "index","type": "uint256"},{"internalType": "bytes32","name": "providedHash","type": "bytes32"}],
      "name": "verifyVC",
      "outputs": [{"internalType": "bool","name": "","type": "bool"}],
      "stateMutability": "view",
      "type": "function"
    }
  ]
  ''';

  Web3Service() {
    _client = Web3Client(RPC_URL, Client());
    _contract = DeployedContract(
      ContractAbi.fromJson(CONTRACT_ABI, 'IdentityManager'),
      EthereumAddress.fromHex(CONTRACT_ADDRESS),
    );
  }

  // Tạo ví mới
  Future<Map<String, String>> createWallet() async {
    final mnemonic = bip39.generateMnemonic();
    final seed = bip39.mnemonicToSeed(mnemonic);
    final privateKey = EthPrivateKey.fromHex(
      seed.sublist(0, 32).map((b) => b.toRadixString(16).padLeft(2, '0')).join()
    );
    
    final address = await privateKey.extractAddress();
    
    // Lưu vào SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mnemonic', mnemonic);
    await prefs.setString('privateKey', privateKey.privateKey.map((b) => b.toRadixString(16).padLeft(2, '0')).join());
    await prefs.setString('address', address.hex);
    
    return {
      'mnemonic': mnemonic,
      'address': address.hex,
    };
  }

  // Import ví từ private key hoặc mnemonic
  Future<String> importWallet(String privateKeyOrMnemonic) async {
    try {
      EthPrivateKey privateKey;
      
      if (privateKeyOrMnemonic.split(' ').length > 1) {
        // Đây là mnemonic
        final seed = bip39.mnemonicToSeed(privateKeyOrMnemonic);
        privateKey = EthPrivateKey.fromHex(
          seed.sublist(0, 32).map((b) => b.toRadixString(16).padLeft(2, '0')).join()
        );
      } else {
        // Đây là private key
        privateKey = EthPrivateKey.fromHex(privateKeyOrMnemonic);
      }
      
      final address = await privateKey.extractAddress();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('privateKey', privateKey.privateKey.map((b) => b.toRadixString(16).padLeft(2, '0')).join());
      await prefs.setString('address', address.hex);
      
      _credentials = privateKey;
      
      return address.hex;
    } catch (e) {
      throw Exception('Invalid private key or mnemonic: $e');
    }
  }

  // Load ví đã lưu
  Future<String?> loadWallet() async {
    final prefs = await SharedPreferences.getInstance();
    final privateKeyHex = prefs.getString('privateKey');
    
    if (privateKeyHex == null) return null;
    
    _credentials = EthPrivateKey.fromHex(privateKeyHex);
    final address = await _credentials.extractAddress();
    
    return address.hex;
  }

  // Đăng ký DID
  Future<String> registerDID(String orgID, String hashData, String uri) async {
    final function = _contract.function('registerDID');
    final result = await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: [
          orgID,
          hexToBytes(hashData),
          uri,
        ],
      ),
      chainId: 11155111, // Sepolia chain ID
    );
    
    return result;
  }

  // Phát hành VC
  Future<String> issueVC(String orgID, String hashCredential, String uri) async {
    final function = _contract.function('issueVC');
    final result = await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: [
          orgID,
          hexToBytes(hashCredential),
          uri,
        ],
      ),
      chainId: 11155111,
    );
    
    return result;
  }

  // Lấy thông tin DID
  Future<Map<String, dynamic>> getDID(String orgID) async {
    final function = _contract.function('dids');
    final result = await _client.call(
      contract: _contract,
      function: function,
      params: [orgID],
    );
    
    return {
      'owner': (result[0] as EthereumAddress).hex,
      'hashData': bytesToHex(result[1] as List<int>),
      'uri': result[2] as String,
      'active': result[3] as bool,
    };
  }

  // Lấy danh sách VC
  Future<List<Map<String, dynamic>>> getVCs(String orgID) async {
    final lengthFunction = _contract.function('getVCLength');
    final lengthResult = await _client.call(
      contract: _contract,
      function: lengthFunction,
      params: [orgID],
    );
    
    final length = (lengthResult[0] as BigInt).toInt();
    final vcs = <Map<String, dynamic>>[];
    
    final getVCFunction = _contract.function('getVC');
    
    for (var i = 0; i < length; i++) {
      final result = await _client.call(
        contract: _contract,
        function: getVCFunction,
        params: [orgID, BigInt.from(i)],
      );
      
      vcs.add({
        'index': i,
        'hashCredential': bytesToHex(result[0] as List<int>),
        'uri': result[1] as String,
        'issuer': (result[2] as EthereumAddress).hex,
        'valid': result[3] as bool,
      });
    }
    
    return vcs;
  }

  // Xác minh VC
  Future<bool> verifyVC(String orgID, int index, String providedHash) async {
    final function = _contract.function('verifyVC');
    final result = await _client.call(
      contract: _contract,
      function: function,
      params: [
        orgID,
        BigInt.from(index),
        hexToBytes(providedHash),
      ],
    );
    
    return result[0] as bool;
  }

  // Thu hồi VC
  Future<String> revokeVC(String orgID, int index) async {
    final function = _contract.function('revokeVC');
    final result = await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: [
          orgID,
          BigInt.from(index),
        ],
      ),
      chainId: 11155111,
    );
    
    return result;
  }

  // Lấy số dư ETH
  Future<EtherAmount> getBalance() async {
    final address = await _credentials.extractAddress();
    return await _client.getBalance(address);
  }

  // Helper functions
  List<int> hexToBytes(String hex) {
    if (hex.startsWith('0x')) {
      hex = hex.substring(2);
    }
    return List<int>.generate(
      hex.length ~/ 2,
      (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16),
    );
  }

  String bytesToHex(List<int> bytes) {
    return '0x${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
  }

  void dispose() {
    _client.dispose();
  }
}