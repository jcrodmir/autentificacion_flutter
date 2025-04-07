import 'package:flutter/material.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';

class ProductsCard extends StatelessWidget {

  final Product product;

  const ProductsCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
      _ImageViewer(images: product.images),
      Text(product.title),
      const SizedBox(height: 20,)
      ]

    );
  }
}


class _ImageViewer extends StatelessWidget {

  final List<String> images;


  const _ImageViewer({ required this.images});

  @override
  Widget build(BuildContext context) {

    if (images.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset("asset/no-image.jpg", fit: BoxFit.cover, height: 250,),
      );
      
    }

    return ClipRRect(
       borderRadius: BorderRadius.circular(20),
        child: FadeInImage(
          height: 250,
          fadeOutDuration: const Duration(milliseconds: 100),
          fadeInDuration: const Duration(milliseconds: 200),          fit: BoxFit.cover,
          placeholder: const AssetImage("assets/loaders/bottle-loader.gif"), 
          image: NetworkImage(images.first))
    );
  }
}