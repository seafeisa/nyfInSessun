#import "SSBLEReadWriteData.h"


@implementation SSBLEReadWriteData

@synthesize data;
@synthesize dataType;
@synthesize seq;
@synthesize maxRewriteCount;
@synthesize readValues;
@synthesize writeDateTime;
@synthesize ifReply;
@synthesize replyCount;

- (id)init {
    self = [super init];
    if (self) {
        data = nil;
        dataType = -1;
        seq = -1;
        maxRewriteCount = NSIntegerMax;
        writeDateTime = -1;
        ifReply = NO;
        replyCount = 0;
    }
    return self;
}

@end
