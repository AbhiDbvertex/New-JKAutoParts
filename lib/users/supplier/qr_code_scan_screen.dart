// import 'dart:convert';
//
// import 'package:jkautomed/ajugnu_constants.dart';
// import 'package:jkautomed/ajugnu_navigations.dart';
// import 'package:jkautomed/models/ajugnu_product.dart';
// import 'package:jkautomed/users/common/AjugnuFlushbar.dart';
// import 'package:jkautomed/users/common/backend/api_handler.dart';
// import 'package:jkautomed/users/common/common_widgets.dart';
// import 'package:jkautomed/users/supplier/backend/product_repository.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// // import 'package:qr_code_scanner/qr_code_scanner.dart';
//
// class QrCodeScanScreen extends StatefulWidget {
//   const QrCodeScanScreen({super.key});
//
//   @override
//   State<StatefulWidget> createState() {
//     return QrCodeScanState();
//   }
// }
//
// class QrCodeScanState extends State<QrCodeScanScreen> {
//   QRViewController? controller;
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   bool isWorking = true;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AjugnuTheme.appColorScheme.onSurface,
//       extendBodyBehindAppBar: true,
//       appBar: CommonWidgets.appbar(
//         'Scan Product Code',
//         systemUiOverlayStyle: SystemUiOverlayStyle(
//           statusBarColor: AjugnuTheme.appColorScheme.onSurface,
//           statusBarIconBrightness: Brightness.light,
//           systemNavigationBarColor: AjugnuTheme.appColorScheme.onSurface,
//           systemNavigationBarIconBrightness: Brightness.light,
//         ),
//         color: AjugnuTheme.appColorScheme.onPrimary
//       ),
//       body: Stack(
//         children: [
//           _buildQrView(context),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               padding: const EdgeInsets.all(36.0),
//               child: IconButton(
//                 style: ButtonStyle(
//                   backgroundColor: WidgetStatePropertyAll<Color>(AjugnuTheme.appColorScheme.onPrimary)
//                 ),
//                 onPressed: () async {
//                   await controller?.toggleFlash();
//                   setState(() {});
//                 },
//                 icon: FutureBuilder(
//                   future: controller?.getFlashStatus(),
//                   builder: (BuildContext context, AsyncSnapshot<bool?> snapshot) {
//                     return Icon(snapshot.data == true ? Icons.flash_on : Icons.flash_off);
//                   },
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQrView(BuildContext context) {
//     // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
//     var scanArea = (MediaQuery.of(context).size.width < 400 ||
//         MediaQuery.of(context).size.height < 400)
//         ? 150.0
//         : 300.0;
//     // To ensure the Scanner view is properly sizes after rotation
//     // we need to listen for Flutter SizeChanged notification and update controller
//     return QRView(
//       key: qrKey,
//       onQRViewCreated: _onQRViewCreated,
//       overlay: QrScannerOverlayShape(
//           borderColor: AjugnuTheme.appColorScheme.inversePrimary,
//           borderRadius: 10,
//           borderLength: 30,
//           borderWidth: 10,
//           cutOutSize: scanArea),
//       onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
//     );
//   }
//
//   void _onQRViewCreated(QRViewController controller) {
//     setState(() {
//       this.controller = controller;
//     });
//     controller.scannedDataStream.listen((scanData) async {
//       if (isWorking) {
//         isWorking = false;
//
//         Map<String, dynamic> data;
//         try {
//           data = jsonDecode(scanData.code ?? '{}');
//           adebug(data, tag: 'scanned data');
//           String id = data['_id'];
//           CommonWidgets.showProgress();
//           var product = await ProductRepository().getProductByIDForCustomer(id);
//           CommonWidgets.removeProgress();
//           if (product != null) {
//             AjugnuNavigations.customerItemDetailScreen(product: product, type: AjugnuNavigations.typePopAndPush,);
//           } else {
//             Navigator.pop(context);
//             AjugnuFlushbar.showError(context, 'Product may have deleted.');
//           }
//         } catch (error) {
//           CommonWidgets.removeProgress();
//           Navigator.pop(context);
//           AjugnuFlushbar.showError(context, 'Scanned QR can not be opened in Ajugnu Application. ($error)');
//           adebug(error, tag: 'Scanner');
//         }
//       }
//
//     });
//   }
//
//   void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
//     if (!p) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('no Permission')),
//       );
//     }
//   }
//
// }