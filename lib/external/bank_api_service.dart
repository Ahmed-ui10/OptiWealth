class BankAPIService {
  Future<List<Map<String, dynamic>>> fetchTransactions(String accountId) async {
    await Future.delayed(Duration(seconds: 1));
    return [];
  }
}