import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ordermate/utils/extensions.dart';
import 'package:ordermate/utils/hive_types.dart';

part 'product.g.dart';
part 'product.freezed.dart';

@HiveType(typeId: HiveTypes.product)
@freezed
class Product extends Equatable with _$Product {
  const Product._();

  @JsonSerializable(explicitToJson: true)
  const factory Product({
    @HiveField(0) required String name,
    @HiveField(1) required String unit,
    @HiveField(2) required num price,
    @HiveField(3) required int sortingKey,
    @HiveField(4) required String hexColor,
  }) = _Product;

  Color get color => ColorX.fromHex(hexColor);

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  @override
  List<Object?> get props => [
        name,
        unit,
        price,
        sortingKey,
        hexColor,
      ];
}
