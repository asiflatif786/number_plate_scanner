class StateModel {
  final String stateId;
  final String stateName;

  const StateModel({required this.stateId, required this.stateName});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      stateId: json['state_id'] as String? ?? '',
      stateName: json['state_name'] as String? ?? '',
    );
  }

  @override
  String toString() => stateName;
}
