class CartCountEmitter {
  static int cartCounts = 0;
  static Function(int cartCounts)? _callbacks;

  static void listen(Function(int cartCounts) callbacks) {
    CartCountEmitter._callbacks = callbacks;
    _notify();
  }

  static void _notify() {
    if (_callbacks != null) {
      _callbacks!(cartCounts);
    }
  }

  static void reset() {
    cartCounts = 0;
    _notify();
  }

  static void set(int cartCounts) {
    CartCountEmitter.cartCounts = cartCounts;
    _notify();
  }

  static void accum(int quantity) {
    cartCounts += quantity;
    _notify();
  }
}