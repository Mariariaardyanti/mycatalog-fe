import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/features/catalog/presentation/providers/product_provider.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Catalog Produk')),
      body: Builder(
        builder: (_) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.status == ProductStatus.error) {
            return Center(child: Text(provider.error ?? 'Terjadi kesalahan'));
          }

          if (provider.products.isEmpty) {
            return const Center(child: Text('Produk kosong'));
          }

          return ListView.builder(
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              final product = provider.products[index];

              return ListTile(
                leading: product.imageUrl.isNotEmpty
                    ? Image.network(product.imageUrl, width: 50)
                    : const Icon(Icons.image_not_supported),
                title: Text(product.name),
                subtitle: Text('Rp ${product.price.toStringAsFixed(0)}'),
                trailing: const Icon(Icons.arrow_forward_ios),
              );
            },
          );
        },
      ),
    );
  }
}