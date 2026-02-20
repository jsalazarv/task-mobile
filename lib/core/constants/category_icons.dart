import 'package:flutter/material.dart';

/// Catálogo curado de iconos disponibles para categorías personalizadas.
///
/// Organizados por dominio del hogar para facilitar el picker.
abstract final class CategoryIcons {
  static const List<IconData> all = [
    // Limpieza
    Icons.cleaning_services_outlined,
    Icons.wash_outlined,
    Icons.dry_cleaning_outlined,
    Icons.shower_outlined,

    // Cocina
    Icons.restaurant_outlined,
    Icons.dining_outlined,
    Icons.kitchen_outlined,
    Icons.coffee_outlined,
    Icons.local_pizza_outlined,

    // Jardín / Exterior
    Icons.yard_outlined,
    Icons.park_outlined,
    Icons.local_florist_outlined,
    Icons.grass_outlined,
    Icons.water_drop_outlined,

    // Compras
    Icons.shopping_cart_outlined,
    Icons.local_grocery_store_outlined,
    Icons.shopping_bag_outlined,
    Icons.receipt_long_outlined,

    // Organización
    Icons.inventory_2_outlined,
    Icons.folder_outlined,
    Icons.category_outlined,
    Icons.checklist_outlined,

    // Hogar / Muebles
    Icons.home_outlined,
    Icons.weekend_outlined,
    Icons.king_bed_outlined,
    Icons.bathtub_outlined,
    Icons.lightbulb_outlined,

    // Otros
    Icons.pets_outlined,
    Icons.fitness_center_outlined,
    Icons.medical_services_outlined,
    Icons.star_outline,
  ];
}
