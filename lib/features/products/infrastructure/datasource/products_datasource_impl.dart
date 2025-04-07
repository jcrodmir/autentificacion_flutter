import 'package:dio/dio.dart';
import 'package:teslo_shop/config/const/environment.dart';
import 'package:teslo_shop/features/products/domain/datasource/products_datasource.dart';
import 'package:teslo_shop/features/products/domain/entities/product.dart';
import 'package:teslo_shop/features/products/infrastructure/errors/product_erros.dart';
import 'package:teslo_shop/features/products/infrastructure/mappers/product_mapper.dart';

class ProductsDatasourceImpl extends ProductsDatasource{
  
  late final Dio dio;
  final String accessToken;

  ProductsDatasourceImpl(
    {required this.accessToken}
  ): dio=Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      headers: {"Authorization": "Bearer $accessToken"}
    )
  );

   @override
  Future<Product> createUpdate(Map<String, dynamic> productLike) async {
    
    try {
      
      final String? productId = productLike['id'];
      final String method = (productId == null) ? 'POST' : 'PATCH';
      final String url = (productId == null) ? '/products' : '/products/$productId';

      productLike.remove('id');

      final response = await dio.request(
        url,
        data: productLike,
        options: Options(
          method: method
        )
      );

      final product = ProductMapper.jsonToEntity(response.data);
      return product;

    } catch (e) {
      print(e.toString());
      throw Exception();
    }


  }
  @override
  Future<Product> getProductsById(String id) async{
    try {
      final responses = await dio.get("/products/$id");
      final product= ProductMapper.jsonToEntity(responses.data);

      return product;
    
    }on DioException catch (e) {
      if(e.response!.statusCode==404) throw ProductNotFound();
      throw Exception();
    }catch(e){
      throw Exception();
    }
  }

  @override
  Future<List<Product>> getProductsByPage({int limit = 10, int offset = 0}) async{
    final response = await dio.get<List>("/products?limit=$limit&offset=$offset");
    final List<Product> products= [];

    for (var product in response.data ?? []) {

      products.add(ProductMapper.jsonToEntity(product));
    }

    return products;
  }

  @override
  Future<List<Product>> searcProductByTerm(String term) {
    // TODO: implement searcProductByTerm
    throw UnimplementedError();
  }
}