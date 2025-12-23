mixin class Observable {
  final List<Function> _observers = [];

  void notifyObservers() {
    for (final observer in _observers) {
      observer.call();
    }
  }

  void addObserver(final Function observer) {
    _observers.add(observer);
  }

  void removeObserver(final Function observer) {
    _observers.remove(observer);
  }
}
