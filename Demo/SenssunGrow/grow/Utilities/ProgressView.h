//
//  ProgressView.h
//  ProgressView
//
//  Created by Admin on 9/27/13.
//  Copyright (c) 2013 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ProgressStripes,
    ProgressGradient,
    ProgressSolid
} ProgressType;

@interface ProgressView : UIView

@property (nonatomic) CGFloat value;
@property (nonatomic) NSString *unit;
@property (nonatomic) CGFloat maxValue;
@property (nonatomic) CGFloat minValue;
@property (nonatomic) CGFloat progress;

@property (nonatomic, strong) UIColor  *color UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor  *groundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSNumber *flat UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSNumber *animate UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSNumber *showText UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSNumber *borderRadius UI_APPEARANCE_SELECTOR;

@property (nonatomic) ProgressType type;

@end
