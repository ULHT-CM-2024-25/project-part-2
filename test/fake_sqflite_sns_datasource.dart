import 'package:flutter/cupertino.dart';
import 'package:prjectcm/data/sqflite_sns_datasource.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/models/evaluation_report.dart';

class FakeSqfliteSnsDataSource extends SqfliteSnsDataSource {

  final List<Hospital> hospitals = [];

  @override
  Future<bool> init() async {
    return true;
  }

  @override
  Future<List<Hospital>> getAllHospitals() async {
    return hospitals;
  }

  @override
  Future<void> attachEvaluation(int hospitalId, EvaluationReport report) async {
    final hospital = hospitals.firstWhere((element) => element.id == hospitalId);
    hospital.reports.add(report);
  }

  @override
  Future<void> insertHospital(Hospital hospital) async {
    debugPrint('inserting hospital ${hospital.name}');
    hospitals.add(hospital);
  }

  @override
  Future<Hospital> getHospitalDetailById(int hospitalId) async {
    return hospitals.firstWhere((element) => element.id == hospitalId);
  }

  @override
  Future<List<Hospital>> getHospitalsByName(String name) async {
    return hospitals.where((element) => element.name.toLowerCase().contains(name.toLowerCase())).toList();
  }
}