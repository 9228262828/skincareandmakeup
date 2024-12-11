//
//  SkinCareRecommendationData.h
//  PerfectLib
//
//  Created by PX Chen on 2020/7/6.
//  Copyright © 2020 Perfect Corp. All rights reserved.
//

#import <PerfectLibRecommendationHandler/PerfectLibRecommendationHandler.h>

NS_ASSUME_NONNULL_BEGIN

@class PFSurveyAnswer;
@class PFSkinAnalysisData;

/**
A class used for obtain the recommended products.
 
 - Use `RecommendationHandler:getRecommendedResult` with this class's instance to get the recommended products.
*/
NS_SWIFT_NAME(SkinCareRecommendationData)
@interface PFSkinCareRecommendationData : RecommendationData

/**
 Initialize a `SkinCareSurveyAnswer` object.
 @param skinAnalysisData The array of `SkinAnalysisData3`.
 @param skinAge The skin age acquired from `PFSkinCare getOverallScoreWithCompletion:`
 @param overallScore The overall score acquired from `PFSkinCare getOverallScoreWithCompletion:`
 @param skinCareSurveyAnswer The `SkinCareSurveyAnswer` instance.
 @return A `SkinCareRecommendationData`
 */
- (instancetype)initWithSkinAnalysisData:(NSArray <PFSkinAnalysisData *> *)skinAnalysisData skinAge:(int)skinAge overallScore:(int)overallScore andSurveyAnswer:(PFSurveyAnswer * _Nullable)skinCareSurveyAnswer;

@property (nonatomic, strong, readonly) NSArray <PFSkinAnalysisData *> *skinAnalysisData;

/// The answer(s) from the survey form's question(s).
@property (nonatomic, strong, readonly) PFSurveyAnswer *skinCareSurveyAnswer;

@property (nonatomic, readonly) int skinAge;

@property (nonatomic, readonly) int overallScore;

@end

NS_ASSUME_NONNULL_END
