class Environment {
  // Smart Contract Configuration
  static const String CONTRACT_ADDRESS = '0x002F3e4e86E1eFC79C628d81B9942bb423ecFE35';
  
  // Network Configuration
  static const String SEPOLIA_RPC_URL = 'https://eth-sepolia.g.alchemy.com/v2/YOUR_ALCHEMY_KEY';
  static const int SEPOLIA_CHAIN_ID = 11155111;
  
  // Thay thế YOUR_ALCHEMY_KEY bằng key thực tế từ Alchemy
  // Để lấy Alchemy API Key:
  // 1. Truy cập https://dashboard.alchemy.com/
  // 2. Đăng ký/Đăng nhập
  // 3. Tạo một App mới cho Sepolia Testnet
  // 4. Copy API Key và thay thế vào đây
  
  // Có thể sử dụng RPC công khai (không ổn định):
  // static const String SEPOLIA_RPC_URL = 'https://rpc.sepolia.org';
  
  // Hoặc Infura:
  // static const String SEPOLIA_RPC_URL = 'https://sepolia.infura.io/v3/YOUR_INFURA_KEY';
  
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
  
  static String get rpcUrl {
    // Trong production, nên load từ secure storage hoặc environment variable
    return SEPOLIA_RPC_URL;
  }
  
  static String get contractAddress {
    return CONTRACT_ADDRESS;
  }
  
  static int get chainId {
    return SEPOLIA_CHAIN_ID;
  }
}