#import "Food.h"


typedef NS_ENUM(int, NutritionEnum) {
    NutritionKCAL = 0,
    NutritionSOD = 1,
    NutritionFAT = 2,
    NutritionPROT = 3,
    NutritionCARB = 4,
    NutritionCHOL = 5,
    NutritionFIBR = 6
};


@interface HistoryNutrition : NSObject

@property (nonatomic, copy) NSString *historyID;
@property (nonatomic, copy) NSString *recordDate;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *foodID;
@property (nonatomic, assign) double foodMassG;
@property (nonatomic, assign) double foodMassOZ;
@property (nonatomic, assign) double fatTotal;
@property (nonatomic, assign) double fatPolyunsaturated;
@property (nonatomic, assign) double fatMonounsaturated;
@property (nonatomic, assign) double fatSaturated;
@property (nonatomic, assign) double cholesterol;
@property (nonatomic, assign) double sodium;
@property (nonatomic, assign) double carbohydrates;
@property (nonatomic, assign) double fiber;
@property (nonatomic, assign) double sugar;
@property (nonatomic, assign) double energyConsumed;
@property (nonatomic, assign) double protein;

@property (nonatomic, assign) int year;
@property (nonatomic, assign) int month;
@property (nonatomic, assign) int day;
@property (nonatomic, assign) int hour;

@property (nonatomic, copy) NSString *eatTime;
@property (nonatomic, copy) NSString *foodName;
@property (nonatomic, copy) NSString *picture;
@property (nonatomic, retain) Food *relateFood;

@property (nonatomic, assign) BOOL ifSelected;

- (void)reset;

@end
