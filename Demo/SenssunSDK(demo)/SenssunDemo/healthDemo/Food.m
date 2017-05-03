#import "Food.h"


@implementation Food

@synthesize foodID;
@synthesize foodName;
@synthesize picture;
//@synthesize cagID;
@synthesize energyConsumed;
@synthesize protein;
@synthesize fatTotal;
@synthesize carbohydrates;
@synthesize fiber;
@synthesize cholesterol;
@synthesize sodium;
@synthesize lang;
@synthesize userID;

@synthesize folder;

- (id)init {
    self = [super init];
    if (self) {
        foodID = @"";
        foodName = @"";
        picture = @"";
        //cagID = [FoodCag getCagCustom];
        energyConsumed = 0;
        protein = 0;
        fatTotal = 0;
        carbohydrates = 0;
        fiber = 0;
        cholesterol = 0;
        sodium = 0;
        lang = 0;
        userID = @"";
        
        //FoodCag *cag = [BLL getFoodCag:cagID];
        //folder = cag.folder;
    }
    return self;
}

- (void)update:(Food *)food {
    food.foodName = foodName;
    food.picture = foodName;
    food.energyConsumed = energyConsumed;
    food.protein = protein;
    food.fatTotal = fatTotal;
    food.carbohydrates = carbohydrates;
    food.fiber = fiber;
    food.cholesterol = cholesterol;
    food.sodium = sodium;
}

@end
