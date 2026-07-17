class ApiEndpoints {
  const ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Books
  static const String books = '/books';
  static String bookById(int id) => '/books/$id';
  static const String booksSearch = '/books/search';

  // Authors
  static const String authors = '/authors';
  static String authorById(int id) => '/authors/$id';

  // Categories
  static const String categories = '/categories';
  static String categoryById(int id) => '/categories/$id';

  // Orders
  static const String orders = '/orders';
  static String orderById(int id) => '/orders/$id';
  static String ordersByUser(int userId) => '/orders/user/$userId';
  static String orderStatus(int id) => '/orders/$id/status';

  // Users
  static const String users = '/users';
  static String userById(int id) => '/users/$id';
}
