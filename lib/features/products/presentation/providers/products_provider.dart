import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';
import 'package:teslo_shop/features/products/presentation/providers/product_repository_provider.dart';


//STATE NOTIFIER PROVIDER



//Provider que es el que amarra a los dos
final productsProvider = StateNotifierProvider<ProductsNotifier,ProductsState>((ref) {
  
  final productsRepository=ref.watch(productsRepositoryProvider);
  return ProductsNotifier(productsRepository: productsRepository); 
});

//Mandamos el estado al notifier y aqui se crean los metodos logicos.
class ProductsNotifier extends StateNotifier<ProductsState>{

  //lo invocamos entre otras cosas para cargar la página
  final ProductsRepository productsRepository;

  //Constructor con el repositorio
  //llamamos al super con el ProducState y dentro invocamos el metodo.
  ProductsNotifier({
    required this.productsRepository
  }):super(ProductsState()){
    loadNextPage();
  }

  Future<bool> createOrUpdateProduct( Map<String,dynamic> productLike ) async {

    try {
      final product = await productsRepository.createUpdate(productLike);
      final isProductInList = state.products.any((element) => element.id == product.id );

      if ( !isProductInList ) {
        state = state.copyWith(
          products: [...state.products, product]
        );
        return true;
      }

      state = state.copyWith(
        products: state.products.map(
          (element) => ( element.id == product.id ) ? product : element,
        ).toList()
      );
      return true;

    } catch (e) {
      return false;
    }


  }


  Future loadNextPage() async{

      //Si isLoading es true o es la ultima página se acabo no hay que mirar
      //ya que si esta cargando debemos dejar que cargue y si es la ultima no hay mas cosas.

      if (state.isLastPage || state.isLoading) return;

      //Si entra quiere decir que debemos cargar nuevamente por lo tanto pasa a true
      state= state.copyWith(isLoading: true);

      //carga de nueva página
      final products= await productsRepository.getProductsByPage(limit: state.limit,offset: state.offset);

      //Si esta vacio es que no hay más productos por lo tanto ultima pagina y ya ha cargado todo
      if (products.isEmpty) {
          state = state.copyWith(
            isLastPage: true,
            isLoading: false);
          return;
      }
      //si hay productos entonces no es ultima pagina ha dejado de cargar, pedimos los siguientes 10 con offsset y juntos los
      //productos de antes con los de ahora.
      state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset +10, 
        products: [...state.products, ...products]);
  }

}



//Creamos estado
class ProductsState{
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Product> products;

  ProductsState({
   this.isLastPage= false, 
   this.limit=10, 
   this.offset=0, 
   this.isLoading=false, 
   this.products= const[]});
  
  ProductsState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    List<Product>? products,
}) => ProductsState(
      isLastPage: isLastPage ?? this.isLastPage,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products
  );
}