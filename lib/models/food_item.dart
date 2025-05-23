// ignore: unused_import
import 'package:flutter/foundation.dart';

class FoodItem {
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['_id'] ?? '',
      name: map['name'] ?? 'Unnamed Item',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: (map['quantity'] ?? 0).toInt(),
      expiryDate: DateTime.parse(map['expiryDate'] ?? DateTime.now().toIso8601String()),
      timeOfCooking: DateTime.parse(map['timeOfCooking'] ?? DateTime.now().toIso8601String()),
      restaurantId: map['restaurantId'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
    );
  }

  final String id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final DateTime expiryDate;
  final DateTime timeOfCooking;
  final String restaurantId;
  final String restaurantName;
  final bool isAvailable;

  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.expiryDate,
    required this.timeOfCooking,
    required this.restaurantId,
    required this.restaurantName,
    this.isAvailable = true,
  });

  // Update fromJson method
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['_id'] ?? '',
      name: json['foodName'] ?? '', // Changed from 'name'
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 0,
      expiryDate: DateTime.parse(json['expiryDate'].toString()),
      timeOfCooking: DateTime.parse(json['timeOfCooking'].toString()),
      restaurantId: json['restaurantId']?.toString() ?? '',
      restaurantName: json['restaurantName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'expiryDate': expiryDate.toIso8601String(),
      'timeOfCooking': timeOfCooking.toIso8601String(),
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'isAvailable': isAvailable,
    };
  }

  FoodItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? quantity,
    DateTime? expiryDate,
    DateTime? timeOfCooking,
    String? restaurantId,
    String? restaurantName,
    bool? isAvailable,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      expiryDate: expiryDate ?? this.expiryDate,
      timeOfCooking: timeOfCooking ?? this.timeOfCooking,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodItem &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.price == price &&
        other.quantity == quantity &&
        other.expiryDate == expiryDate &&
        other.timeOfCooking == timeOfCooking &&
        other.restaurantId == restaurantId &&
        other.restaurantName == restaurantName &&
        other.isAvailable == isAvailable;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      price,
      quantity,
      expiryDate,
      timeOfCooking,
      restaurantId,
      restaurantName,
      isAvailable,
    );
  }
}