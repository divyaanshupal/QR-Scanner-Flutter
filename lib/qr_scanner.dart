import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:myqr/result.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'package:url_launcher/url_launcher.dart'; // For URL launching

const bgColor = Color(0xfffafafa);

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  bool isScanCompleted = false;
  bool isFlashOn = false;
  bool isFrontCamera = false;

  MobileScannerController controller = MobileScannerController();

  void closeScreen() {
    isScanCompleted = false;
  }

  Future<void> _launchUPI(String upiUrl) async {
    try {
      Uri uri = Uri.parse(upiUrl);

      // Validate UPI URL scheme
      if (uri.scheme != 'upi') {
        throw 'Invalid UPI URL format: $upiUrl';
      }

      debugPrint('Launching UPI URL: $upiUrl');

      // Check if the URL can be launched
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'No UPI app found to handle this URL.';
      }
    } catch (e) {
      debugPrint('Error launching UPI URL: $e');

      // Allow rescan on error
      setState(() {
        isScanCompleted = false;
      });

      // Provide feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer: const Drawer(),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isFlashOn = !isFlashOn;
              });
              controller.toggleTorch();
            },
            icon: Icon(
              Icons.flash_on,
              color: isFlashOn ? Colors.blue : Colors.grey,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isFrontCamera = !isFrontCamera;
              });
              controller.switchCamera();
            },
            icon: Icon(
              Icons.camera_front,
              color: isFrontCamera ? Colors.blue : Colors.grey,
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
        title: const Text(
          "QR SCANNER",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Place QR in area",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "scanning will start automatically",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  MobileScanner(
                    controller: controller,
                    onDetect: (capture) {
                      if (!isScanCompleted) {
                        final List<Barcode> barcodes = capture.barcodes;
                        final Barcode? firstBarcode = barcodes.isNotEmpty ? barcodes.first : null;

                        String code = firstBarcode?.rawValue ?? '---';
                        debugPrint('Scanned QR Code: $code'); // Debug scanned content
                        isScanCompleted = true;

                        if (code.startsWith('upi://')) {
                          // Handle UPI QR Code
                          _launchUPI(code);
                        } else {
                          // Navigate to the Result screen for non-UPI codes
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResultScreen(
                                closeScreen: closeScreen,
                                code: code,
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  QRScannerOverlay(overlayColor: bgColor),
                ],
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  "Developed with ❤ by DIVYANSHU PAL",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


//testing 