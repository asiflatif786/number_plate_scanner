class StateModel {
  final String stateId;
  final String stateName;

  const StateModel({required this.stateId, required this.stateName});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      stateId: json['state_id']?.toString() ??
          json['id']?.toString() ??
          json['state_name']?.toString() ??
          json['name']?.toString() ??
          '',
      stateName: json['state_name']?.toString() ??
          json['name']?.toString() ??
          json['state']?.toString() ??
          '',
    );
  }

  @override
  String toString() => stateName;
}
