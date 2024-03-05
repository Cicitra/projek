import 'dart:convert';

import 'package:sepatu/provider/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as bdg;
import 'package:sepatu/models/menu_model.dart';
import 'package:http/http.dart' as myHttp;
import 'package:open_whatsapp/open_whatsapp.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => CartProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.green),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  TextEditingController namaController = TextEditingController();
  TextEditingController nomorMejaController = TextEditingController();
  final String urlBuah =
      "https://script.google.com/macros/s/AKfycbzul1ZjJPx1WGLwJpw1A_XhDAJMTgGNOA-9xOkp_DLv0JufQ9SawrEvl_msxy2LzQGUmA/exec";
  Future<List<MenuModel>> getAllData() async {
    List<MenuModel> listMenu = [];
    var response = await myHttp.get(Uri.parse(urlBuah));

    List data = json.decode(response.body);

    data.forEach((element) {
      listMenu.add(MenuModel.fromJson(element));
    });

    return listMenu;
  }

  void openDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 280,
            child: Column(
              children: [
                Text(
                  "Nama",
                  style: TextStyle(fontFamily: 'montserrat'),
                ),
                TextFormField(
                  controller: namaController,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Nomor Meja",
                  style: TextStyle(fontFamily: 'montserrat'),
                ),
                TextFormField(
                  controller: nomorMejaController,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
                SizedBox(
                  height: 20,
                ),
                Consumer<CartProvider>(
                  builder: (context, value, _) {
                    String strPesanan = "";
                    value.cart.forEach((element) {
                      strPesanan = strPesanan +
                          "\n" +
                          element.name +
                          "(" +
                          element.quantity.toString() +
                          ")";
                    });
                    return ElevatedButton(
                        onPressed: () async {
                          String phone = "+62 877 5628 3025";
                          String pesanan = "Nama :" +
                              namaController.text +
                              "\n" +
                              "Nomor Meja: " +
                              nomorMejaController.text +
                              "\n" +
                              "Pesanan: " +
                              "\n" +
                              strPesanan;
                         FlutterOpenWhatsapp.sendSingleMessage(
                          phone, pesanan
                         );
                         print(pesanan);
                        },
                        child: Text("Pesan Sekarang"));
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.openDialog(context);
        },
        child: bdg.Badge(
          badgeContent: Consumer<CartProvider>(
            builder: (context, value, _) {
              return Text((value.total > 0) ? value.total.toString() : "",
                  style: TextStyle(fontFamily: 'Montserrat'));
            },
          ),
          child: Icon(Icons.shopping_bag),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: widget.getAllData(),
          builder: (context, AsyncSnapshot<List<MenuModel>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    MenuModel menu = snapshot.data![index];
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(menu.image),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  menu.name,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  menu.description,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Rp. ${menu.price}",
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Provider.of<CartProvider>(context,
                                                    listen: false)
                                                .addRemove(
                                                    menu.name, menu.id, false);
                                          },
                                          icon: Icon(Icons.remove_circle,
                                              color: Colors.red),
                                        ),
                                        SizedBox(width: 10),
                                        Consumer<CartProvider>(
                                          builder: (context, value, _) {
                                            var id = value.cart.indexWhere(
                                                (element) =>
                                                    element.menuId ==
                                                    snapshot.data![index].id);
                                            return Text(
                                              (id == -1)
                                                  ? "0"
                                                  : value.cart[id].quantity
                                                      .toString(),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 15,
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(width: 10),
                                        IconButton(
                                          onPressed: () {
                                            Provider.of<CartProvider>(context,
                                                    listen: false)
                                                .addRemove(
                                                    menu.name, menu.id, true);
                                          },
                                          icon: Icon(Icons.add_circle,
                                              color: Colors.green),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: Text("Data Was Not Found"),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
