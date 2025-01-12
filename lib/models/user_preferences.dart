import 'dart:convert';

UserPreference userPreferenceFromJson(String str) =>
    UserPreference.fromMap(json.decode(str));

String userPreferenceToJson(UserPreference data) => json.encode(data.toMap());

class UserPreference {
  final String name;
  final String value;

  const UserPreference({required this.name, required this.value});

  factory UserPreference.fromMap(Map<String, dynamic> json) => UserPreference(
        name: json["Name"],
        value: json["Value"],
      );

  Map<String, dynamic> toMap() => {
        "Name": name,
        "Value": value,
      };
}
