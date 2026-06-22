import 'package:example/app/api/shoe_api.dart';
import 'package:example/app/models/shoe.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';

part 'home_store.crystalline.dart';

@StoreClass()
abstract class _HomeStore extends Store {
  _HomeStore(this.api);
  final ShoeApi api;

  final shoes = ListData<Shoe>([]);

  @override
  Future<void> onInitialize() async {
    shoes.failure = null;
    shoes.operation = Operation.read;
    publish();

    try {
      shoes.addAll((await api.getAll()).mapToDataList());
      shoes.operation = Operation.none;
      publish();
    } catch (e) {
      shoes.failure = Failure(e.toString());
      shoes.operation = Operation.none;
      publish();
    }
  }
}
