//
//  ShadeFinderRecommendationResult.h
//  PerfectLib
//
//  Created by I Lin on 2023/3/23.
//  Copyright © 2023 Perfect Corp. All rights reserved.
//
#import <PerfectLibRecommendationHandler/PerfectLibRecommendationHandler.h>
@class ShadeFinderProductSet;
NS_ASSUME_NONNULL_BEGIN
/**
    Recommendation result of shade finder
 */
@interface ShadeFinderRecommendationResult : RecommendationResult

/// The Recommendation result of shade finder product sets
@property (nonatomic, strong, readonly) NSArray <ShadeFinderProductSet *> *productSets;

@end

NS_ASSUME_NONNULL_END
