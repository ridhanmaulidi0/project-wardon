import '../../models/category_model.dart';
import '../../models/menu_item_model.dart';
import '../../models/user_model.dart';

class SampleData {
  static const List<UserModel> defaultUsers = [
    UserModel(
      id: 'usr_admin',
      name: 'Owner WARDON',
      email: 'admin@wardon.com',
      role: UserRole.admin,
    ),
    UserModel(
      id: 'usr_kasir1',
      name: 'Kasir Shift Pagi',
      email: 'kasir@wardon.com',
      role: UserRole.kasir,
    ),
  ];

  static const List<CategoryModel> defaultCategories = [
    CategoryModel(id: 'all', name: 'Semua', icon: 'all_inclusive'),
    CategoryModel(id: 'kopi', name: 'Kopi', icon: 'coffee'),
    CategoryModel(id: 'non_kopi', name: 'Non-Kopi', icon: 'local_drink'),
    CategoryModel(id: 'makanan', name: 'Makanan', icon: 'restaurant'),
    CategoryModel(id: 'snack', name: 'Camilan', icon: 'bakery_dining'),
  ];

  static const List<MenuItemModel> defaultMenuItems = [
    // Kopi
    MenuItemModel(
      id: 'm_1',
      categoryId: 'kopi',
      name: 'Es Kopi Susu Wardon',
      price: 18000,
      stock: 45,
      description: 'Espresso blend khas Wardon dengan susu segar & gula aren organik',
    ),
    MenuItemModel(
      id: 'm_2',
      categoryId: 'kopi',
      name: 'Americano Dingin',
      price: 15000,
      stock: 50,
      description: 'Double shot espresso dengan air dingin segar',
    ),
    MenuItemModel(
      id: 'm_3',
      categoryId: 'kopi',
      name: 'Caramel Macchiato',
      price: 24000,
      stock: 30,
      description: 'Espresso dengan vanilla syrup, susu steam dan saus caramel',
    ),
    MenuItemModel(
      id: 'm_4',
      categoryId: 'kopi',
      name: 'Kopi Tubruk Robusta',
      price: 10000,
      stock: 60,
      description: 'Kopi tubruk tradisional dengan aroma mantap',
    ),
    MenuItemModel(
      id: 'm_5',
      categoryId: 'kopi',
      name: 'Cafe Latte Panas',
      price: 20000,
      stock: 35,
      description: 'Smooth espresso dengan susu steam lembut',
    ),

    // Non Kopi
    MenuItemModel(
      id: 'm_6',
      categoryId: 'non_kopi',
      name: 'Matcha Latte Ice',
      price: 22000,
      stock: 25,
      description: 'Matcha murni Uji dengan susu segar creamy',
    ),
    MenuItemModel(
      id: 'm_7',
      categoryId: 'non_kopi',
      name: 'Signature Chocolate',
      price: 20000,
      stock: 30,
      description: 'Cokelat Belgia pekat dengan racikan rahasia',
    ),
    MenuItemModel(
      id: 'm_8',
      categoryId: 'non_kopi',
      name: 'Lemon Tea Segar',
      price: 12000,
      stock: 40,
      description: 'Teh melati wangi dengan perasan lemon asli',
    ),

    // Makanan
    MenuItemModel(
      id: 'm_9',
      categoryId: 'makanan',
      name: 'Nasi Goreng Kampung WARDON',
      price: 25000,
      stock: 20,
      description: 'Nasi goreng bumbu terasi, telur ceplok & kerupuk',
    ),
    MenuItemModel(
      id: 'm_10',
      categoryId: 'makanan',
      name: 'Mie Nyemek Spesial',
      price: 18000,
      stock: 25,
      description: 'Mie kuah kental gurih pedas manis dengan sayuran',
    ),

    // Snack
    MenuItemModel(
      id: 'm_11',
      categoryId: 'snack',
      name: 'Roti Bakar Cokelat Keju',
      price: 16000,
      stock: 30,
      description: 'Roti bakar tebal dengan limpahan keju cheddar & meises',
    ),
    MenuItemModel(
      id: 'm_12',
      categoryId: 'snack',
      name: 'Pisang Goreng Crispy',
      price: 15000,
      stock: 35,
      description: 'Pisang kepok manis renyah dengan taburan gula aren',
    ),
    MenuItemModel(
      id: 'm_13',
      categoryId: 'snack',
      name: 'Kentang Goreng Bolognese',
      price: 18000,
      stock: 20,
      description: 'French fries garing disiram saus daging gurih',
    ),
  ];
}

