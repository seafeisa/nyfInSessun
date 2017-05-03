//
//  UIBasegroundView.m
//  grow
//
//  Created by admin on 15-5-21.
//  Copyright (c) 2015年 senssun. All rights reserved.
//

#import "UserList.h"
#import "UIBasegroundView.h"

@implementation UIBasegroundView

- (id)init
{
    self = [super init];
    if (self)
    {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (void)initialize
{
//    NSLog(@"58");
    [self updateView];
}

- (void)updateView
{
    UserProfile *currentKid = [UserList sharedInstance].currentKid;
    if (nil != currentKid)
    {
        self.backgroundColor = [currentKid themeColor];
    }
    
    if (0 == [[UserList sharedInstance].kidsArray count])
    {
        self.backgroundColor = COLOR_THEME_PURPLE;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
