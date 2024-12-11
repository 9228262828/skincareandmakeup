//
//  SkinCareProduct.h
//  PerfectLib
//
//  Created by PX Chen on 2020/7/10.
//  Copyright © 2020 Perfect Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The structure of Skin care product inventory.
 */
@interface Inventory : NSObject

/**
 Get the inventory product Guid.
 */
@property (nonatomic, readonly, nullable) NSString *inventoryId;

/**
 Get the inventory product quantiry.
 */
@property (nonatomic, readonly, nullable) NSNumber *quantity;

@end


/**
 The structure of Skin care product.
 */
@interface SkinCareProduct : NSObject

/**
 The brand name of the product.
 */
@property (nonatomic, readonly, nullable) NSString *brandName;

/**
 The thumbnail url of the product.
 */
@property (nonatomic, readonly, nullable) NSString *imageUrl;

/**
 The unique identifier of the product.
 */
@property (nonatomic, readonly, nullable) NSString* productId;

/**
 The name of the product.
 */
@property (nonatomic, readonly, nullable) NSString *productName;

/**
 The type of the product.
 */
@property (nonatomic, readonly, nullable) NSString *skuType;

/**
 The shopping link or more info link of the product.
 */
@property (nonatomic, readonly, nullable) NSString *actionUrl;

/**
 The "customized" value for the product.
 */
@property (nonatomic, readonly, nullable) NSString *customerInfo;

/**
 The products list of the products contained in a routine
 */
@property (nonatomic, readonly, nullable) NSArray<SkinCareProduct*>* products;

/**
 Retrieve an inventory list of skin care products.
 @param inventoryIds the list of product GUIDs
 */
+ (void)getInventory:(NSArray*)inventoryIds
          completion:(void (^)(NSArray<Inventory*>* inventories,  NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
