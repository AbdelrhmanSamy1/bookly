class Book {
  final int id;
  final String title;
  final String isbn;
  final String? description;
  final double price;
  final int stockQuantity;
  final int? publishedYear;
  final String authorName;
  final int authorId;
  final String categoryName;
  final int categoryId;

  const Book({
    required this.id,
    required this.title,
    required this.isbn,
    this.description,
    required this.price,
    required this.stockQuantity,
    this.publishedYear,
    required this.authorName,
    required this.authorId,
    required this.categoryName,
    required this.categoryId,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      isbn: json['isbn'] ?? '',
      description: json['description'],
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      stockQuantity: json['stockQuantity'] ?? 0,
      publishedYear: json['publishedYear'],
      authorName: json['authorName'] ?? '',
      authorId: json['authorId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      categoryId: json['categoryId'] ?? 0,
    );
  }

  bool get inStock => stockQuantity > 0;
}

class Author {
  final int id;
  final String name;
  final String? bio;
  final String? nationality;

  const Author({
    required this.id,
    required this.name,
    this.bio,
    this.nationality,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      bio: json['bio'],
      nationality: json['nationality'],
    );
  }
}

class Category {
  final int id;
  final String name;
  final String? description;

  const Category({
    required this.id,
    required this.name,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}

class PageResponse<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final bool isLast;

  const PageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.isLast,
  });
}

class BookFilter {
  final String? title;
  final String? authorName;
  final String? categoryName;
  final double? minPrice;
  final double? maxPrice;
  final int? publishedYear;
  final bool? inStock;
  final int page;
  final int size;
  final String sortBy;
  final String sortDir;

  const BookFilter({
    this.title,
    this.authorName,
    this.categoryName,
    this.minPrice,
    this.maxPrice,
    this.publishedYear,
    this.inStock,
    this.page = 0,
    this.size = 20,
    this.sortBy = 'title',
    this.sortDir = 'asc',
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'sortDir': sortDir,
    };
    if (title != null && title!.isNotEmpty) params['title'] = title;
    if (authorName != null && authorName!.isNotEmpty) {
      params['authorName'] = authorName;
    }
    if (categoryName != null && categoryName!.isNotEmpty) {
      params['categoryName'] = categoryName;
    }
    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    if (publishedYear != null) params['publishedYear'] = publishedYear;
    if (inStock != null) params['inStock'] = inStock;
    return params;
  }

  BookFilter copyWith({
    String? title,
    String? authorName,
    String? categoryName,
    double? minPrice,
    double? maxPrice,
    int? publishedYear,
    bool? inStock,
    int? page,
    int? size,
    String? sortBy,
    String? sortDir,
  }) {
    return BookFilter(
      title: title ?? this.title,
      authorName: authorName ?? this.authorName,
      categoryName: categoryName ?? this.categoryName,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      publishedYear: publishedYear ?? this.publishedYear,
      inStock: inStock ?? this.inStock,
      page: page ?? this.page,
      size: size ?? this.size,
      sortBy: sortBy ?? this.sortBy,
      sortDir: sortDir ?? this.sortDir,
    );
  }
}
