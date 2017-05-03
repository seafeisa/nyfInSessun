#import "Unit.h"
#import <sqlite3.h>


@implementation Unit

@synthesize UnitID;
@synthesize UnitName;
@synthesize IsBaseUnit;
@synthesize ExchangeRate;

- (id)init {
    self = [super init];
    if (self) {
        UnitID = @"";
        UnitName = @"";
        IsBaseUnit = 0;
        ExchangeRate = 0;
    }
    return self;
}

#pragma mark Weight
+ (NSMutableArray *)getWeightUnits {
    NSMutableArray *list = [NSMutableArray array];
    
    Unit *unit = [[Unit alloc] init];
    unit.UnitID = @"kg";
    unit.UnitName = @"kg";
    unit.IsBaseUnit = 1;
    unit.ExchangeRate = 1.0f;
    [list addObject:unit];
    
    unit = [[Unit alloc] init];
    unit.UnitID = @"lb";
    unit.UnitName = @"lb";
    unit.IsBaseUnit = 0;
    unit.ExchangeRate = 2.2046226;
    [list addObject:unit];
    
    unit = [[Unit alloc] init];
    unit.UnitID = @"st";
    unit.UnitName = @"st";
    unit.IsBaseUnit = 0;
    unit.ExchangeRate = 0.157473;
    [list addObject:unit];

    return list;
}

+ (NSMutableDictionary *)getWeightUnitDictionary {
    NSMutableDictionary *idToDataMap = [NSMutableDictionary dictionary];
    
    NSMutableArray *list = [Unit getWeightUnits];
    for (Unit *unit in list) {
        [idToDataMap setObject:unit forKey:unit.UnitID];
    }
    
    return idToDataMap;
}

#pragma mark Height
+ (NSMutableArray *)getHeightUnits {
    NSMutableArray *list = [NSMutableArray array];
    
    Unit *unit = [[Unit alloc] init];
    unit.UnitID = @"cm";
    unit.UnitName = @"cm";
    unit.IsBaseUnit = 1;
    unit.ExchangeRate = 1.0f;
    [list addObject:unit];
    
    unit = [[Unit alloc] init];
    unit.UnitID = @"in";
    unit.UnitName = @"in";
    unit.IsBaseUnit = 0;
    unit.ExchangeRate = 0.3937008;
    [list addObject:unit];
    
    return list;
}

+ (NSMutableDictionary *)getHeightUnitDictionary {
    NSMutableDictionary *idToDataMap = [NSMutableDictionary dictionary];
    
    NSMutableArray *list = [Unit getHeightUnits];
    for (Unit *unit in list) {
        [idToDataMap setObject:unit forKey:unit.UnitID];
    }
    
    return idToDataMap;
}

@end
