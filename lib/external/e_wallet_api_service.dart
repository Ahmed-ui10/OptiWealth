class EWalletAPIService {
  Future<List<Map<String, dynamic>>> fetchTransactions(String walletId) async {
    await Future.delayed(Duration(seconds: 1));
    return [];
  }
}