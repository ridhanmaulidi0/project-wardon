class StoreSettingsModel {
  final String storeName;
  final String tagline;
  final String address;
  final String phone;
  final String receiptFooter;
  final bool enableTax;
  final double taxRate;

  const StoreSettingsModel({
    this.storeName = 'WARDON',
    this.tagline = 'Warung Kopi & Eatery',
    this.address = 'Jl. Kopi No. 1, Indonesia',
    this.phone = '0812-3456-7890',
    this.receiptFooter = 'Terima kasih atas kunjungan Anda!\nNikmati hari Anda bersama WARDON ☕',
    this.enableTax = false,
    this.taxRate = 0.11,
  });

  StoreSettingsModel copyWith({
    String? storeName,
    String? tagline,
    String? address,
    String? phone,
    String? receiptFooter,
    bool? enableTax,
    double? taxRate,
  }) {
    return StoreSettingsModel(
      storeName: storeName ?? this.storeName,
      tagline: tagline ?? this.tagline,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      enableTax: enableTax ?? this.enableTax,
      taxRate: taxRate ?? this.taxRate,
    );
  }

  Map<String, dynamic> toJson() => {
        'storeName': storeName,
        'tagline': tagline,
        'address': address,
        'phone': phone,
        'receiptFooter': receiptFooter,
        'enableTax': enableTax,
        'taxRate': taxRate,
      };

  factory StoreSettingsModel.fromJson(Map<String, dynamic> json) =>
      StoreSettingsModel(
        storeName: json['storeName'] as String? ?? 'WARDON',
        tagline: json['tagline'] as String? ?? 'Warung Kopi & Eatery',
        address: json['address'] as String? ?? 'Jl. Kopi No. 1, Indonesia',
        phone: json['phone'] as String? ?? '0812-3456-7890',
        receiptFooter: json['receiptFooter'] as String? ??
            'Terima kasih atas kunjungan Anda!\nNikmati hari Anda bersama WARDON ☕',
        enableTax: json['enableTax'] as bool? ?? false,
        taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.11,
      );
}

