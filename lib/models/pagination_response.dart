class PaginationResponse<e> {
  final e item;
  final int currentPage;
  final int totalPages;

  const PaginationResponse({required this.item, required this.currentPage, required this.totalPages});
}