// To parse this JSON data, do
// final resultRecord = resultRecordFromJson(jsonString);

import 'dart:convert';

ResultRecord resultRecordFromJson(String str) =>
    ResultRecord.fromJson(json.decode(str));

String resultRecordToJson(ResultRecord data) => json.encode(data.toJson());

class ResultRecord {
  ResultRecord({
    required this.score,
    required this.time,
    required this.keyStrokes,
    required this.wordAccuracy,
    required this.accuracy,
    required this.wpm,
    required this.correctWords,
    required this.wrongWords,
  });

// Results data
  String score;
  String time;
  String keyStrokes;
  String wordAccuracy;
  String accuracy;
  String wpm;
  String correctWords;
  String wrongWords;

  factory ResultRecord.fromJson(Map<String, dynamic> json) => ResultRecord(
        score: json["score"],
        time: json["time"],
        keyStrokes: json["keyStrokes"],
        wordAccuracy: json["wordAccuracy"],
        accuracy: json["accuracy"],
        wpm: json["wpm"],
        correctWords: json["correctWords"],
        wrongWords: json["wrongWords"],
      );

  Map<String, dynamic> toJson() => {
        "score": score,
        "time": time,
        "keyStrokes": keyStrokes,
        "wordAccuracy": wordAccuracy,
        "accuracy": accuracy,
        "wpm": wpm,
        "correctWords": correctWords,
        "wrongWords": wrongWords
      };
}
