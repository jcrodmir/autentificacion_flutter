import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/products/domain/entities/product.dart';
import 'package:teslo_shop/features/products/presentation/providers/forms/product_form_provider.dart';
import 'package:teslo_shop/features/products/presentation/providers/product_provider.dart';
import 'package:teslo_shop/features/shared/shared.dart';
import 'package:teslo_shop/features/shared/widgets/custom_product_field.dart';
import 'package:teslo_shop/features/shared/widgets/fullscreen_loader.dart';


class ProductScreen extends ConsumerWidget {

  final String productId;
  const ProductScreen({super.key, required this.productId});

  void showSnackbar(BuildContext context){
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Producto Actualizado"))
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final productState= ref.watch(productProvider(productId));
    final producto= productState.product;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Editar Producto"),
          actions: [
            IconButton(onPressed: ()async{
              final photoPath = await CameraGalleryServiceImpl().selectPhoto();
              if(photoPath == null) return;

              ref.read(productFormProvider(producto!).notifier).updateProductImage(photoPath);
             

              }, icon: const Icon(Icons.photo_library_outlined),),
            IconButton(onPressed: ()async{
              final photoPath = await CameraGalleryServiceImpl().takePhoto();
              if(photoPath == null) return;
              ref.read(productFormProvider(producto!).notifier).updateProductImage(photoPath);
              photoPath;

            }, icon: const Icon(Icons.camera_alt_outlined),)
          ],
        ),
        body:productState.isLoading ? const FullscreenLoader():_ProductView(product: productState.product!),
        
        floatingActionButton: FloatingActionButton(onPressed: (){
          if(producto == null)return ;
          ref.read(productFormProvider(producto).notifier).onFormSubmit().then((value) {
            if(!value) return;
            showSnackbar(context);
          });
      
        },child:const Icon(Icons.save_as_outlined)),
      ),
    );
  }
}


class _ProductView extends ConsumerWidget {

  final Product product;

  const _ProductView({required this.product});

  @override
  Widget build(BuildContext context,WidgetRef ref) {

    final productForm= ref.watch(productFormProvider(product));

    final textStyles = Theme.of(context).textTheme;

    return ListView(
      children: [
    
          SizedBox(
            height: 250,
            width: 600,
            child: _ImageGallery(images: productForm.imagenes),
          ),
    
          const SizedBox( height: 10 ),
          Center(child: Text( productForm.title.value, style: textStyles.titleSmall )),
          const SizedBox( height: 10 ),
          _ProductInformation( product: product ),
          
        ],
    );
  }
}


class _ProductInformation extends ConsumerWidget {
  final Product product;
  const _ProductInformation({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref ) {

  final productForm= ref.watch(productFormProvider(product));
    

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Generales'),
          const SizedBox(height: 15 ),
          CustomProductField( 
            isTopField: true,
            label: 'Nombre',
            initialValue: productForm.title.value,
            onChanged: ref.read(productFormProvider(product).notifier).onTitleChanged ,
            errorMessage: productForm.title.errorMessage,
          ),
          CustomProductField( 
            isTopField: true,
            label: 'Slug',
            initialValue: productForm.slug.value,
            onChanged: ref.read(productFormProvider(product).notifier).onSlugChanged ,
            errorMessage: productForm.slug.errorMessage,
          ),
          CustomProductField( 
            isBottomField: true,
            label: 'Precio',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            initialValue: productForm.price.value.toString(),
            onChanged:(value)  => ref.read(productFormProvider(product).notifier).onPriceChanged(double.tryParse(value) ?? -1) ,
            errorMessage: productForm.price.errorMessage,
          ),

          const SizedBox(height: 15 ),
          const Text('Extras'),

          _SizeSelector(selectedSizes: productForm.size, onSizesChange: ref.read(productFormProvider(product).notifier).onSizeChanged ),
          const SizedBox(height: 5 ),
          _GenderSelector( selectedGender: productForm.gender,onGenderChange: ref.read(productFormProvider(product).notifier).onGenderChanged ),
          

          const SizedBox(height: 15 ),
          CustomProductField( 
            isTopField: true,
            label: 'Existencias',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            initialValue: productForm.inStock.value.toString(),
            onChanged:(value)  => ref.read(productFormProvider(product).notifier).onStockChanged(int.tryParse(value) ?? -1) ,
            errorMessage: productForm.inStock.errorMessage,
          ),

          CustomProductField( 
            maxLines: 6,
            label: 'Descripción',
            keyboardType: TextInputType.multiline,
            initialValue: product.description,
            onChanged:ref.read(productFormProvider(product).notifier).onDescriptionChanged,
          ),

          CustomProductField( 
            isBottomField: true,
            maxLines: 2,
            label: 'Tags (Separados por coma)',
            keyboardType: TextInputType.multiline,
            initialValue: product.tags.join(', '),
            onChanged:ref.read(productFormProvider(product).notifier).onTagChanged,
          ),


          const SizedBox(height: 100 ),
        ],
      ),
    );
  }
}


class _SizeSelector extends StatelessWidget {
  final List<String> selectedSizes;
  final List<String> sizes = const['XS','S','M','L','XL','XXL','XXXL'];


  final void Function(List<String> selectedSizes) onSizesChange;
  const _SizeSelector({required this.selectedSizes, required this.onSizesChange});




   @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      emptySelectionAllowed: true,
      showSelectedIcon: false,
      segments: sizes.map((size) {
        return ButtonSegment(
          value: size, 
          label: Text(size, style: const TextStyle(fontSize: 10))
        );
      }).toList(), 
      selected: Set.from( selectedSizes ),
      onSelectionChanged: (newSelection) {
        FocusScope.of(context).unfocus();
        onSizesChange( List.from(newSelection) );
      },
      multiSelectionEnabled: true,
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final String selectedGender;
  final List<String> genders = const['men','women','kid'];
  final void Function(String selectedGender) onGenderChange;

  final List<IconData> genderIcons = const[
    Icons.man,
    Icons.woman,
    Icons.boy,
  ];

  const _GenderSelector({required this.selectedGender, required this.onGenderChange});


  @override
  Widget build(BuildContext context) {
    return Center(
      child: SegmentedButton(
        emptySelectionAllowed: true,
        multiSelectionEnabled: false,
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact ),
        segments: genders.map((size) {
          return ButtonSegment(
            icon: Icon( genderIcons[ genders.indexOf(size) ] ),
            value: size, 
            label: Text(size, style: const TextStyle(fontSize: 12))
          );
        }).toList(), 
        selected: { selectedGender },
        onSelectionChanged: (newSelection) {
          FocusScope.of(context).unfocus();
          onGenderChange(newSelection.first);
        },
      ),
    );
  }
}


class _ImageGallery extends StatelessWidget {
  final List<String> images;
  const _ImageGallery({required this.images});

  @override
  Widget build(BuildContext context) {

    if(images.isEmpty){
      return ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: Image.asset('assets/images/no-image.jpg', fit: BoxFit.cover ));

    }

    return PageView(
      scrollDirection: Axis.horizontal,
      controller: PageController(
        viewportFraction: 0.5
      ),
      children: images.map((image){

          late ImageProvider imageProvider;
          if(image.startsWith("http")){
            imageProvider= NetworkImage(image);
          } else{
            imageProvider= FileImage(File(image) );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: FadeInImage(
                fit: BoxFit.cover,
                placeholder: const AssetImage("assets/loaders/bottle-loader.gif"), 
                image: imageProvider),
            ),
          );
      }).toList(),
    );
  }
}