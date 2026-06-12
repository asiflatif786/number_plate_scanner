import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<TransactionEntity> createTransaction(TransactionEntity transaction);

  Future<TransactionEntity> approveTransaction(String transactionRef);

  Future<TransactionEntity> declineTransaction(String transactionRef);

  Future<TransactionEntity> verifyTransaction(String transactionRef);

  Future<void> abandonTransaction(String transactionRef);

  Future<List<TransactionEntity>> listTransactions({
    String? agentNumber,
    int page = 1,
    int limit = 20,
  });
}
