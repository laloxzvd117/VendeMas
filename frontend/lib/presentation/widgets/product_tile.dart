import 'package:flutter/material.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final int cartQuantity;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const ProductTile({
    super.key,
    required this.product,
    this.cartQuantity = 0,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = cartQuantity > 0;
    final isLowStock = product.trackStock && product.stock <= product.minStock && product.stock > 0;
    final isOutOfStock = product.trackStock && product.stock <= 0;

    return GestureDetector(
      onTap: isOutOfStock ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.secondaryContainer : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : colorScheme.outlineVariant,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isOutOfStock ? colorScheme.onSurface.withValues(alpha: 0.6) : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.currency(product.price),
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (product.trackStock) ...[
                    const SizedBox(height: 4),
                    _StockLabel(
                      stock: product.stock,
                      isLow: isLowStock,
                      isOut: isOutOfStock,
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 24),
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$cartQuantity',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            if (isSelected && onRemove != null)
              Positioned(
                bottom: 8,
                right: 8,
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton.outlined(
                    onPressed: onRemove,
                    icon: const Icon(Icons.remove, size: 16),
                    padding: EdgeInsets.zero,
                    iconSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StockLabel extends StatelessWidget {
  final int stock;
  final bool isLow;
  final bool isOut;

  const _StockLabel({required this.stock, required this.isLow, required this.isOut});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (isOut) {
      return Text(
        'Agotado',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colorScheme.error),
      );
    }
    if (isLow) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Quedan $stock',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onTertiaryContainer,
          ),
        ),
      );
    }
    return Text(
      '$stock en stock',
      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
    );
  }
}
