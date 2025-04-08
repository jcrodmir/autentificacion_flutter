

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:teslo_shop/config/config.dart';
import 'package:teslo_shop/features/products/domain/entities/product.dart';
import 'package:teslo_shop/features/products/presentation/providers/providers.dart';

import '../../../../shared/shared.dart';

//El family es para que yo pueda mandar el producto
final  productFormProvider = StateNotifierProvider.autoDispose.family<ProductFormNotifier,ProductFormState,Product>(
  (ref,product){

    //final createUpdateCallback = ref.watch(productsRepositoryProvider).createUpdate;
    final createUpdateCallback = ref.watch(productsProvider.notifier).createOrUpdateProduct;
    return ProductFormNotifier(
      product: product,
      onSubmitCallback: createUpdateCallback,
      );
  }
);




//Emite los datos que trabaja otro ente
class ProductFormNotifier extends StateNotifier<ProductFormState>{

  final Future<bool> Function(Map<String,dynamic>productLike)?  onSubmitCallback;


  ProductFormNotifier({
    this.onSubmitCallback,
    required Product product,
  }) : super(
    ProductFormState(
    id: product.id,
    title: Title.dirty(product.title),
    slug:Slug.dirty(product.slug),
    price:Price.dirty(product.price),
    inStock:Stock.dirty(product.stock),
    size:product.sizes,
    gender:product.gender,
    description: product.description,
    tags: product.tags.join(","),
    imagenes:product.images
    )
  );


  Future<bool> onFormSubmit() async{

    _touchEverything();

    if(!state.isFormValid) return false;

    //No ha yque hacer nada porque no me mando la funcion para ejecutarla
    if (onSubmitCallback == null) return false;

    final productLike= {
      "id":state.id,
      "title":state.title.value,
      "price": state.price.value,
      "description": state.description,
      "slug": state.slug.value,
      "stock":state.inStock.value,
      "sizes": state.size,
      "gender": state.gender,
      "tags": state.tags.split(","),
      "images":state.imagenes.map((image) => image.replaceAll("${Environment.apiUrl}/files/product/", "")).toList()
    };
    
    try {
      
       return onSubmitCallback!(productLike);
    } catch (e) {
      return false;
    }
  }


  void _touchEverything(){
    state= state.copyWith(
      isFormValid: Formz.validate(
        [
        Title.dirty(state.title.value),
        Slug.dirty(state.slug.value),
        Price.dirty(state.price.value),
        Stock.dirty(state.inStock.value),
        ]
      )
    );
  }

  void onTitleChanged(String value){
    state= state.copyWith(
      title: Title.dirty(value),
      isFormValid: Formz.validate([
        Title.dirty(value),
        Slug.dirty(state.slug.value),
        Price.dirty(state.price.value),
        Stock.dirty(state.inStock.value),
      ])
    );
  }

  void updateProductImage(String path){
    state= state.copyWith(
      imagenes:[path, ...state.imagenes]
    );
  }
    void onSlugChanged(String value){
    state= state.copyWith(
      slug: Slug.dirty(value),
      isFormValid: Formz.validate([
        Slug.dirty(value),
        Title.dirty(state.title.value),
        Price.dirty(state.price.value),
        Stock.dirty(state.inStock.value),
      ])
    );
    }

    void onPriceChanged(double value){
    state= state.copyWith(
      price: Price.dirty(value),
      isFormValid: Formz.validate([
        Price.dirty(value),
        Title.dirty(state.title.value),
        Slug.dirty(state.slug.value),
        Stock.dirty(state.inStock.value),
      ])
    );
    }

    void onStockChanged(int value){
    state= state.copyWith(
      inStock: Stock.dirty(value),
      isFormValid: Formz.validate([
        Stock.dirty(value),
        Title.dirty(state.title.value),
        Slug.dirty(state.slug.value),
        Price.dirty(state.price.value),
      ])
    );
    }


    void onSizeChanged(List<String> sizes){
      //Solo se envia uno porque los sizes se pueden mandar nulos y por ello no es necesario validarlo con el resto
      state=state.copyWith(
        size:sizes
      );
    }

    void onGenderChanged(String gender){
      state=state.copyWith(
        gender:gender
      );
    }

    void onDescriptionChanged(String description){
      state=state.copyWith(
        description:description
      );
    }

    void onTagChanged(String tags){
      state=state.copyWith(
        tags:tags
      );
    }
}

class ProductFormState {
  final bool isFormValid;
  final String? id;
  final Title title;
  final Slug slug;
  final Price price;
  final List<String> size;
  final String gender;
  final Stock inStock;
  final String description;
  final String tags;
  final List<String> imagenes;

  ProductFormState({
  this.isFormValid = false, 
  this.id, 
  this.title = const Title.dirty(""), 
  this.slug = const Slug.dirty(""), 
  this.price = const Price.dirty(0), 
  this.size= const [] ,
  this.gender = "men", 
  this.inStock= const Stock.dirty(0), 
  this.description= "", 
  this.tags = "", 
  this.imagenes = const []
  });


  ProductFormState copyWith({
   bool? isFormValid,
   String? id,
   Title? title,
   Slug? slug,
   Price? price,
   List<String>? size,
   String? gender,
   Stock? inStock,
   String? description,
   String? tags,
   List<String>? imagenes,

  })=> ProductFormState(

    isFormValid: isFormValid ?? this.isFormValid,
    id: id ?? this.id,
    title: title ?? this.title,
    slug: slug ?? this.slug,
    price: price ?? this.price,
    size: size ?? this.size,
    gender: gender ?? this.gender,
    inStock: inStock ?? this.inStock,
    description: description ?? this.description,
    tags: tags ?? this.tags,
    imagenes: imagenes ?? this.imagenes,

  );
  
}