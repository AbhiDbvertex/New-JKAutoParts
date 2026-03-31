import 'package:flutter/material.dart';

import 'AjugnuFlushbar.dart';
import 'backend/google_apis.dart';
import 'common_widgets.dart';
import 'form_validator.dart';

class PostalPinDialog extends StatefulWidget {
  final Function(List<String>) onSubmit;

  final List<String> initialPinCodes;

  const PostalPinDialog(
      {super.key, required this.onSubmit, this.initialPinCodes = const []});

  @override
  State<StatefulWidget> createState() => _PostalPinDialogState();
}

class _PostalPinDialogState extends State<PostalPinDialog> {
  final TextEditingController _pinController = TextEditingController();
  final List<String> _pins = [];

  Future<void> _addPin() async {
    String postalCode = _pinController.text.trim();
    if (FormValidators.isValidPostalCode(postalCode) == null) {
      FocusManager.instance.primaryFocus?.unfocus();
      CommonWidgets.showProgress();
      try {
        if (await GoogleApis().isPostalCodeValid(postalCode)) {
          CommonWidgets.removeProgress();
          setState(() {
            var item = double.parse(postalCode).toInt().toString();
            if (!_pins.contains(item)) {
              _pins.add(item);
            }
            _pinController.clear();
          });
        } else {
          CommonWidgets.removeProgress();
          AjugnuFlushbar.showError(context, 'Please add a valid pin code');
        }
      } catch (error) {
        CommonWidgets.removeProgress();
        AjugnuFlushbar.showError(
            context, 'Something went wrong while adding pin code.');
      }
    } else {
      AjugnuFlushbar.showError(context,
          FormValidators.isValidPostalCode(postalCode) ?? 'Invalid pin code.');
    }
  }

  @override
  void initState() {
    super.initState();

    _pins.addAll(widget.initialPinCodes);
  }

  void _submitPins() {
    widget.onSubmit(_pins);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFf0f4f3), // Light greenish color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: const Text(
        "Add Postal PINs",
        style: TextStyle(
          color: Color(0xFF2c5f2d), // Dark green color
          fontWeight: FontWeight.bold,
        ),
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5, // Limit height
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              onEditingComplete: () {
                _addPin();
              },
              maxLength: FormValidators.maxPinCodeLength,
              decoration: InputDecoration(
                hintText: "Enter Postal Code",
                counterText: '',
                prefixIcon: const Icon(
                  Icons.pin,
                  color: Color(0xFF2c5f2d),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2c5f2d), // Dark green
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                minimumSize: const Size(double.infinity, 36), // Button height
              ),
              onPressed: _addPin,
              child: const Text(
                "Add",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10.0),
            SizedBox(
              height: _pins.isEmpty
                  ? 100
                  : MediaQuery.of(context).size.height * 0.29,
              width: 50,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _pins.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _pins[index].toString(),
                      style: const TextStyle(
                        color: Color(0xFF2c5f2d), // Dark green
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _pins.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Color(0xFF2c5f2d)), // Dark green
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2c5f2d), // Dark green
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            minimumSize: Size(80, 36), // Button size
          ),
          onPressed: _submitPins,
          child: const Text(
            "Submit",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

void showPostalPinDialog(BuildContext context, List<String> initialPinCodes,
    Function(List<String>) onSubmit) {
  showDialog(
    context: context,
    builder: (context) =>
        PostalPinDialog(onSubmit: onSubmit, initialPinCodes: initialPinCodes),
  );
}
