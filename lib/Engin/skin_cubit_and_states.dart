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

    if (isClosed) return;  // Check before emit
    emit(SkinAnalysisLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');

      print("$token $userId");

      final requestData = {
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

      final response = await Dio().post(
        'https://gomla.sa/wp-json/skin-analysis/v1/skinscoretest',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            "gomlaauth": "Bearer $token",
          },
        ),
        data: requestData,
      );

      print('Full Response: ${response.data}');

      if (response.data is! Map<String, dynamic>) {
        throw FormatException('Invalid response format');
      }

      final responseData = response.data as Map<String, dynamic>;

      if (!responseData.containsKey('data') || responseData['data'] is! Map) {
        throw FormatException('Missing or invalid data in response');
      }

      final skinAnalysis = SkinAnalysisResponse.fromJson(responseData);

      if (isClosed) return; // 🔥 Check before emitting
      emit(SkinAnalysisSuccess(skinAnalysis));

    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Network error';
      if (isClosed) return; // 🔥
      emit(SkinAnalysisError(errorMessage));

    } on FormatException catch (e) {
      if (isClosed) return; // 🔥
      emit(SkinAnalysisError(e.message));

    } catch (e) {
      if (isClosed) return; // 🔥
      emit(SkinAnalysisError('An unexpected error occurred $e'));
      print('Unexpected error: $e');
    }
  }

}

