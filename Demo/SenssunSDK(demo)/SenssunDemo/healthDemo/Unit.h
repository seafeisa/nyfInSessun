#import <Foundation/Foundation.h>


@interface Unit : NSObject

@property (nonatomic, copy) NSString *UnitID;
@property (nonatomic, copy) NSString *UnitName;
@property (nonatomic, assign) int IsBaseUnit;
@property (nonatomic, assign) double ExchangeRate;

#pragma mark Weight
+ (NSMutableArray *)getWeightUnits;
+ (NSMutableDictionary *)getWeightUnitDictionary;

#pragma mark Height
+ (NSMutableArray *)getHeightUnits;
+ (NSMutableDictionary *)getHeightUnitDictionary;

@end
