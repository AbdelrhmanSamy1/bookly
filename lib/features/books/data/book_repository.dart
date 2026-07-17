import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import 'models/book_models.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository(ref.read(dioProvider));
});

class BookRepository {
  final Dio _dio;
  const BookRepository(this._dio);

  Future<List<Book>> getAll() async {
    final response = await _dio.get(ApiEndpoints.books);
    final list = response.data as List<dynamic>;
    return list.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Book> getById(int id) async {
    final response = await _dio.get(ApiEndpoints.bookById(id));
    return Book.fromJson(response.data);
  }

  Future<PageResponse<Book>> search(BookFilter filter) async {
    final response = await _dio.get(
      ApiEndpoints.booksSearch,
      queryParameters: filter.toQueryParams(),
    );
    final data = response.data as Map<String, dynamic>;
    final items = (data['content'] as List<dynamic>)
        .map((e) => Book.fromJson(e as Map<String, dynamic>))
        .toList();
    return PageResponse<Book>(
      content: items,
      totalElements: data['totalElements'] ?? 0,
      totalPages: data['totalPages'] ?? 0,
      currentPage: data['currentPage'] ?? 0,
      isLast: data['last'] ?? true,
    );
  }

  Future<List<Author>> getAuthors() async {
    final response = await _dio.get(ApiEndpoints.authors);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => Author.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Category>> getCategories() async {
    final response = await _dio.get(ApiEndpoints.categories);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
