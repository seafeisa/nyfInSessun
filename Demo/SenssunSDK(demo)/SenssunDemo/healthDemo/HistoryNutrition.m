#import "HistoryNutrition.h"


@implementation HistoryNutrition

@synthesize historyID;
@synthesize recordDate;
@synthesize userID;
@synthesize foodID;
@synthesize foodMassG;
@synthesize foodMassOZ;
@synthesize fatTotal;
@synthesize fatPolyunsaturated;
@synthesize fatMonounsaturated;
@synthesize fatSaturated;
@synthesize cholesterol;
@synthesize sodium;
@synthesize carbohydrates;
@synthesize fiber;
@synthesize sugar;
@synthesize energyConsumed;
@synthesize protein;

@synthesize year;
@synthesize month;
@synthesize day;
@synthesize hour;

@synthesize eatTime;
@synthesize foodName;
@synthesize picture;
@synthesize relateFood;

@synthesize ifSelected;

- (id)init {
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

- (void)reset {
    historyID = @"";
    recordDate = @"";
    userID = @"";
    foodID = @"";
    foodMassG = 0;
    foodMassOZ = 0;
    fatTotal = 0;
    fatPolyunsaturated = -1;
    fatMonounsaturated = -1;
    fatSaturated = -1;
    cholesterol = 0;
    sodium = 0;
    carbohydrates = 0;
    fiber = 0;
    sugar = -1;
    energyConsumed = 0;
    protein = 0;
    
    year = 0;
    month = 0;
    day = 0;
    hour = 0;
    
    eatTime = @"";
    foodName = @"";
    picture = @"";
    relateFood = nil;
    
    ifSelected = NO;
}

- (Food *)relateFood {
    if (!relateFood) {
        //relateFood = [BLL getFood:foodID];
    }
    return relateFood;
}

@end
