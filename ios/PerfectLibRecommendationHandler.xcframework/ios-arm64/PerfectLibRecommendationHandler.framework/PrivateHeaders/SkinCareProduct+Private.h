//
//  SkinCareProduct+Private.h
//  MakeupSDK
//
//  Created by PX Chen on 2020/7/10.
//  Copyright © 2020 Perfect Corp. All rights reserved.
//

#ifndef SkinCareSurvey_Private_h
#define SkinCareSurvey_Private_h

#import <SkinCareProduct.h>

@interface SkinCareProduct ()
@property (nonatomic, strong) NSArray<SkinCareProduct*>* products;
@property (assign, nonatomic) long innerProductId;
@property (nonatomic, strong) NSString* upc;
@property (nonatomic, strong) NSString* customerInfo;

- (instancetype)initWithActionURL:(NSString *)actionURL
                        brandName:(NSString *)brandName
                         imageURL:(NSString *)imageURL
                   innerProductId:(NSNumber *)innerProductId
                              upc:(NSString *)upc
                      productName:(NSString *)productName
                          skuType:(NSString *)skuType
                     customerInfo:(NSString *)customerInfo;

+ (void)getInventory:(NSArray*)productGuids
          isFiltered:(BOOL)isFiltered
          completion:(void (^)(NSArray<Inventory*>* inventories, NSError *error))completion;

@end

#endif
