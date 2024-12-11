//
//  SkinCareRecommendationResult.h
//  PerfectLib
//
//  Created by I Lin on 2023/3/23.
//  Copyright © 2023 Perfect Corp. All rights reserved.
//

#import <PerfectLibRecommendationHandler/PerfectLibRecommendationHandler.h>
@class SkinCareProduct;
NS_ASSUME_NONNULL_BEGIN
/**
    Recommendation result of skincare
 */
@interface SkinCareRecommendationResult : RecommendationResult

/// The Recommendation result of skincare products
@property (nonatomic, strong, readonly) NSArray <SkinCareProduct *> *products;

/// A custom json parsed info of the current recommnedation result
@property (nonatomic, strong, readonly) NSString *extraInfo;

@end

NS_ASSUME_NONNULL_END
