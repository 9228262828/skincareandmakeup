//
//  HairColorSurvey.h
//  PerfectLib
//
//  Created by Alex Lin on 2019/12/11.
//  Copyright © 2019 Perfect Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PerfectLibCore/PFCommon.h>
#import <PerfectLibCore/CancelableTask.h>
#import <PerfectLibRecommendationHandler/PFSurveyForm.h>
#import <PerfectLibRecommendationHandler/RecommendationResult.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RecommendationType) {
    RecommendationTypeNone          = 0,
    RecommendationTypeSkinCare      = 2,
    RecommendationTypeShadeFinder   = 4,
};

@class SurveyView;
@class RecommendationData;
@class SkinCareProduct;

/**
The class handles product recommendations.
 
 - Use `-[RecommendationHandler syncServer:successBlock:failureBlock:progressBlock:]` to get updated survey forms and recommendation rules from the server.
 - Delete downloaded forms and rules from the local storage by calling `-clearAll`.
 - Use `-getSurveyView:frame:successBlock:failureBlock:` to obtain a view for user survey page(s).
 - Use `-getRecommendedResult:data:successBlock:failureBlock:` to get recommended products.
*/
@interface RecommendationHandler : NSObject

+ (instancetype)sharedInstance;

/**
Update survey form and products from server.

@param type the recommendation type
@param successBlock A callback called when the operation completes.
@param failureBlock A callback called when the operation fails.
@param progressBlock A callback called when downloading progress reports.
*/
- (id<CancelableTask> _Nullable)syncServer:(RecommendationType)type successBlock:(void (^)(BOOL succeeded))successBlock failureBlock:(void (^)(NSError* error))failureBlock progressBlock:(void (^)(CGFloat progress))progressBlock;

/**
Delete all downloaded survey forms and recommendation rules.
*/
- (void)clearAll;

/**
Obtain a view for user survey form(s).

@param type the recommendation type
@param successBlock A callback called when the operation succeeds.
@param failureBlock A callback called when the operation fails.
*/
- (void)getSurveyForm:(RecommendationType)type successBlock:(void (^)(PFSurveyForm* surveyForm))successBlock failureBlock:(void (^)(NSError* error))failureBlock;

/**
Get recommended products.

@param data the recommendation data
@param type the recommendation type
@param successBlock A callback called when the operation succeeds.
@param failureBlock A callback called when the operation fails.
*/
- (void)getRecommendedResult:(RecommendationType)type data:(RecommendationData*)data successBlock:(void (^)(RecommendationResult* recommendedProduct))successBlock failureBlock:(void (^)(NSError* error))failureBlock;

@end

NS_ASSUME_NONNULL_END
