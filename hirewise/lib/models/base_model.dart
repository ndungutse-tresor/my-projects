abstract class BaseModel {
  const BaseModel();

  String get id;

  Map<String, dynamic> toMap();

  @override
  String toString() => '$runtimeType(id: $id)';
}
