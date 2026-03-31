class PaginationResult<T> {
  final int currentPage;
  final int totalPages;
  final T data;
  final int notificationCounts;

  PaginationResult({required this.currentPage, required this.totalPages, required this.data, required this.notificationCounts});
}