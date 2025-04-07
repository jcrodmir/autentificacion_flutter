import 'package:teslo_shop/features/products/domain/domain.dart';

class ProductsRepositoryImpl extends ProductsRepository{


  final ProductsDatasource datasource;

  ProductsRepositoryImpl({required this.datasource});


  @override
  Future<Product> createUpdate(Map<String, dynamic> productLike) {
    return datasource.createUpdate(productLike);
  }

  @override
  Future<Product> getProductsById(String id) {
    return datasource.getProductsById(id);
  }

  @override
  Future<List<Product>> getProductsByPage({int limit = 10, int offset = 0}) {
    return datasource.getProductsByPage(limit:limit,offset:offset);
  }

  @override
  Future<List<Product>> searcProductByTerm(String term) {
    return datasource.searcProductByTerm(term);
  }
}