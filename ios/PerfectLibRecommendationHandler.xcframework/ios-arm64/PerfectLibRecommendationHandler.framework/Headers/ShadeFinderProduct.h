//
//  ShadeFinderProduct.h
//  MakeupLib
//
//  Created by Alex Lin on 2019/3/8.
//  Copyright © 2019 Perfect Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PerfectLibCore/PerfectLib.h>

NS_ASSUME_NONNULL_BEGIN
/**
 The enumeration for shade finder product type.
 */
typedef NS_OPTIONS(NSUInteger, ShadeFinderProductType) {
    /// The product is best match.
    ShadeFinderProductTypeBestMatch         = 1 << 0,
    /// The product is warmer.
    ShadeFinderProductTypeWarmer            = 1 << 16,
    /// The product is cooler.
    ShadeFinderProductTypeCooler            = 2 << 16,
    /// The product is lighter.
    ShadeFinderProductTypeLighter           = 1 << 20,
    /// The product is darker.
    ShadeFinderProductTypeDarker            = 2 << 20,
};
/**
 The structure of shade finder product.
 */
@interface ShadeFinderProduct : NSObject
/// The product guid.
@property (nonatomic, strong) NSString* productGuid;
/// The SKU guid of this product.
@property (nonatomic, strong) NSString* skuGuid;
/// The type of this product.
@property (nonatomic, assign) ShadeFinderProductType type;
@end
/**
 The structure of shade finer product set.
 */
@interface ShadeFinderProductSet : NSObject
/// The best match product.
@property (nonatomic, strong, readonly, nullable) ShadeFinderProduct *bestMatch;
/// The warmer product.
@property (nonatomic, strong, readonly, nullable) ShadeFinderProduct *warmer;
/// The cooler product.
@property (nonatomic, strong, readonly, nullable) ShadeFinderProduct *cooler;
/// The darker product.
@property (nonatomic, strong, readonly, nullable) ShadeFinderProduct *darker;
/// The lighter product.
@property (nonatomic, strong, readonly, nullable) ShadeFinderProduct *lighter;
@end

NS_ASSUME_NONNULL_END
