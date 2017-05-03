#import "HistoryWater.h"


@implementation HistoryWater

@synthesize historyID;
@synthesize recordDate;
@synthesize userID;
@synthesize water;

@synthesize year;
@synthesize month;
@synthesize day;
@synthesize hour;

@synthesize minToday;
@synthesize maxToday;
@synthesize totalWater;
@synthesize ifSelected;
@synthesize displayText;

- (id)init {
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

- (void)reset {
    historyID = @"";
    recordDate = -1;
    userID = @"";
    water = 0;
    
    year = 0;
    month = 0;
    day = 0;
    hour = 0;
    
    minToday = @"";
    maxToday = @"";
    totalWater = 0;
    ifSelected = NO;
    displayText = @"";
}

@end