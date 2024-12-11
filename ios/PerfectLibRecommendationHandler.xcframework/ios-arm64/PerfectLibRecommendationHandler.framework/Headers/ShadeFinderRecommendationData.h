//
//  ShadeFinderRecommendationData.h
//  PerfectLibHandlerCore
//
//  Created by Steven Chen on 2020/9/22.
//  Copyright © 2020 Perfect Corp. All rights reserved.
//

#import <PerfectLibRecommendationHandler/PerfectLibRecommendationHandler.h>

NS_ASSUME_NONNULL_BEGIN
@class ShadeFinderData;
@class PFSurveyAnswer;
@class PFShadeFinderDeltaE;

/**
 A class used for obtain the recommended products.
 
 - Use `-[RecommendationHandler getRecommendedResult:data:successBlock:failureBlock:]` with this class's instance to get the recommended products.
*/
@interface ShadeFinderRecommendationData : RecommendationData
/**
 Initialize a `ShadeFinderRecommendationData` object.
 @param shadeFinderData The `ShadeFinderData` instance.
 @param shadeFinderDeltaE The `PFShadeFinderDeltaE` instance.
 @return A `ShadeFinderRecommendationData`
 */
- (instancetype)initWithShadeFinderData:(ShadeFinderData *)shadeFinderData shadeFinderDeltaE:(PFShadeFinderDeltaE *)shadeFinderDeltaE;

/// The analysis data from the `PFShadeFinder`'s delegation.
@property (nonatomic, strong, readonly) ShadeFinderData *shadeFinderData;

@property (nonatomic, strong, readonly) PFShadeFinderDeltaE *deltaE;

@end

NS_ASSUME_NONNULL_END
