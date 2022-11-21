// To parse this JSON data, do
//
//     final resultRecord = resultRecordFromJson(jsonString);

import 'dart:convert';

ResultRecord resultRecordFromJson(String str) =>
    ResultRecord.fromJson(json.decode(str));

String resultRecordToJson(ResultRecord data) => json.encode(data.toJson());

class ResultRecord {
  ResultRecord({
    required this.score,
    required this.time,
  });

  int score;
  String time;

  factory ResultRecord.fromJson(Map<String, dynamic> json) => ResultRecord(
        score: json["score"],
        time: json["time"],
      );

  Map<String, dynamic> toJson() => {
        "score": score,
        "time": time,
      };
}
