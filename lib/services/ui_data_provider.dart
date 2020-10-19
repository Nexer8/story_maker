import 'package:flutter/cupertino.dart';

class UIDataProvider extends ChangeNotifier {
  bool _isGeneralProcessorOperational = false;

  bool get isGeneralProcessorOperational => _isGeneralProcessorOperational;

  set isGeneralProcessorOperational(bool isGeneralProcessorOperational) {
    _isGeneralProcessorOperational = isGeneralProcessorOperational;
    notifyListeners();
  }
}
