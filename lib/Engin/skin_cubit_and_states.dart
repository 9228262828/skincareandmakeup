import 'package:Gomla/shared/network/dio_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class SkinAnalysisState {}

class SkinAnalysisLoading extends SkinAnalysisState {}

class SkinAnalysisSuccess extends SkinAnalysisState {
  final SkinAnalysisResponse response;

  SkinAnalysisSuccess(this.response);
}

class SkinAnalysisError extends SkinAnalysisState {
  final String message;

  SkinAnalysisError(this.message);
}

class SkinAnalysisCubit extends Cubit<SkinAnalysisState> {
  SkinAnalysisCubit() : super(SkinAnalysisLoading());

  Future<void> fetchSkinAnalysis(
      String dryness,
      String redness,
      String oillness,
      String acne,
      String pores,
      String texture,
      String wrinkles,
      String darkspots,
      String darkcircles,
      String radiance,
      String skinage,
      String overallscore) async {
    emit(SkinAnalysisLoading());

    Future<SharedPreferences> prefs = SharedPreferences.getInstance();
    String? token = await prefs.then((value) => value.getString('auth_token'));
    int? userId = await prefs.then((value) => value.getInt('user_id'));

    print("token");
    print(token);
    print(userId);
    print(userId);
    print(userId);
    print(userId);
    print("token");

     var requestData = {
      "user_id": userId,
      "dryness": dryness,
      "redness": redness,
      "oillness": oillness,
      "acne": acne,
      "pores": pores,
      "texture": texture,
      "wrinkles": wrinkles,
      "dark spots": darkspots,
      "dark circles": darkcircles,
      "radiance": radiance,
      "skinage": skinage,
      "overall score": overallscore,
    };

     print("Request data: $requestData");
    try {
      final response = await Dio()
          .post('https://gomla.sa/wp-json/skin-analysis/v1/skinscoretest',
              options: Options(
                headers: {
                  'Content-Type': 'application/json',
                  "gomlaauth": "Bearer $token",
                },
              ),
              data: requestData);

       print('Response: ${response.data}');

       if (response.data is Map<String, dynamic>) {
        final skinAnalysis = SkinAnalysisResponse.fromJson(response.data);
        emit(SkinAnalysisSuccess(skinAnalysis));
      } else {
         emit(SkinAnalysisError("Unexpected response format"));
      }
    } catch (e, stackTrace) {
       print('Error: $e');
      print('Stack trace: $stackTrace');
      emit(SkinAnalysisError("Unexpected error occurred"));
    }
  }
}

