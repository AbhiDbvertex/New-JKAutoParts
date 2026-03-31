class FormValidators {
  static int minPasswordLength = 6;
  static int maxPasswordLength = 10;
  static int maxNameChunkLength = 50;
  static int maxPhoneLength = 10;
  static int maxPinCodeLength = 6;

  static String? isValidEmail(String email) {
    if (email.isEmpty) {
      return 'Email address can not be empty.';
    } else if (!RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$').hasMatch(email)) {
      return 'Please enter a valid email address.';
    } else {
      return null;
    }
  }

  static String? isValidPassword(String password) {
    if (password.isEmpty) {
      return 'Password can not be empty.';
    } else if (password.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters long.';
    } else if (password.length > maxPasswordLength) {
      return 'Password must be less than $maxPasswordLength characters long.';
    } else {
      return null;
    }
  }

  static String? isValidFullname(String fullname) {
    if (fullname.isEmpty) {
      return 'Name can not be empty.';
    } else if (fullname.length > maxNameChunkLength) {
      return 'Name should be less than $maxNameChunkLength characters.';
    } else if (!RegExp(r"^[a-zA-Z ]+$").hasMatch(fullname)) {
      return "Please enter a valid name that does not contain number and symbols.";
    } else {
      return null;
    }
  }

  static String? isValidIndianPhone(String phone) {
    phone = phone.replaceAll(' ', '');
    if (phone.isEmpty) {
      return 'Phone number can not be empty.';
    } else if (phone.length != maxPhoneLength) {
      return 'Phone number should be $maxPhoneLength digits and shouldn\'t contain the country code.';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      return 'Phone number should contain only digits.';
    } else {
      return null;
    }
  }

  static String? isValidPostalCode(String code) {
    if (code.isEmpty) {
      return 'Please enter pin code.';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(code)) {
      return 'Pin code should be in digits only.';
    } else {
      return null;
    }
  }
}
