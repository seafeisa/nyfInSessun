#import <Foundation/Foundation.h>


@interface Food : NSObject

@property (nonatomic, copy) NSString *foodID;
@property (nonatomic, copy) NSString *foodName;
@property (nonatomic, copy) NSString *picture;
//@property (nonatomic, copy) NSString *cagID;
@property (nonatomic, assign) double energyConsumed;
@property (nonatomic, assign) double protein;
@property (nonatomic, assign) double fatTotal;
@property (nonatomic, assign) double carbohydrates;
@property (nonatomic, assign) double fiber;
@property (nonatomic, assign) double cholesterol;
@property (nonatomic, assign) double sodium;
@property (nonatomic, assign) int lang;
@property (nonatomic, retain) NSString *userID;

@property (nonatomic, copy) NSString *folder;

- (void)update:(Food *)food;

@end
