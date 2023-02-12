import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:openfoodfacts/model/Nutrient.dart';
import 'package:openfoodfacts/model/PerSize.dart';
import 'package:openfoodfacts/model/ProductResultV3.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:ringtone_player/ringtone_player.dart';
import 'package:ml_card_scanner/ml_card_scanner.dart';


void main() => runApp(StoragePage());

class StoragePage extends StatefulWidget {
  @override
  _StoragePageState createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  String _scanBarcode = 'Unknown';
  String _productName = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
        .listen((barcode){
        RingtonePlayer.ringtone();
          return print(barcode);
    });
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    ProductQueryConfiguration config = ProductQueryConfiguration(
      barcodeScanRes,
      version: ProductQueryVersion.v3,
    );
    ProductResultV3 product = await OpenFoodAPIClient.getProductV3(config);
    print(product.product?.genericName); // Coca Cola Zero
    print(product.product?.productName); // Coca Cola Zero
    print(product.product?.categoriesTags); // Coca Cola Zero
    // print(product.product?.brands); // Coca-Cola
    // print(product.product?.quantity); // 330ml
    // print(product.product?.nutriments?.getValue(Nutrient.salt, PerSize.oneHundredGrams)); // 0.0212
    // print(product.product?.additives?.names); // [E150d, E338, E950, E951]
    // print(product.product?.allergens?.names); // []
    // print(product.product?.nutriscore); // []

    setState(() {
      _scanBarcode = barcodeScanRes;
      _productName = product.product?.genericName ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: const Text('Barcode scan')),
            body: Builder(builder: (BuildContext context) {
              return Container(
                  alignment: Alignment.center,
                  child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                            onPressed: () => scanBarcodeNormal(),
                            child: Text('Start barcode scan')),
                        ElevatedButton(
                            onPressed: () => scanQR(),
                            child: Text('Start QR scan')),
                        ElevatedButton(
                            onPressed: () => startBarcodeScanStream(),
                            child: Text('Start barcode scan stream')),
                        Text('Scan result : $_scanBarcode\n',
                            style: TextStyle(fontSize: 20)),
                        Text('result : $_productName\n',
                            style: TextStyle(fontSize: 20)),
                        Center(
                          child: Column(
                            children: <Widget>[
                              ElevatedButton(
                                child: Text("Beep Success"),
                                onPressed: () => RingtonePlayer.ringtone(),
                              ),
                              ElevatedButton(
                                child: Text("Beep Fail"),
                                onPressed: () => RingtonePlayer.play(android: Android.alarm, ios: Ios.alarm),
                              ),

                            ],
                          ),
                        ),
                      ]));
            })));
  }
}
