#import "FoodController.h"
#import "Food.h"
#import "HistoryNutrition.h"
#import "AppDelegate.h"
#import "SSBLEDeviceManager.h"


@interface FoodController () <SSBLEDeviceDelegate> {
    double _foodMassG;
    double _foodMassByUnit;
    int _unit;
    Food *_selectFood;
    HistoryNutrition *_eatFood;
}
@end


@implementation FoodController

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //sample apple's nutrition / 100g
    _selectFood = [[Food alloc] init];
    _selectFood.energyConsumed = 237.0f;//unit=kcal
    _selectFood.protein = 1.71f;//unit=g
    _selectFood.fatTotal = 11.11f;//unit=g
    _selectFood.carbohydrates = 34.19f;//unit=g
    _selectFood.fiber = 1.62f;//unit=g
    _selectFood.cholesterol = 0.0f;//unit=mg
    _selectFood.sodium = 266.0f;//unit=mg
    
    _eatFood = [[HistoryNutrition alloc] init];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.bleMgr addDelegate:self];
    [delegate.bleMgr connect:@{self.deviceID: self.advertiseName}];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.bleMgr disconnect:self.deviceID];
    [delegate.bleMgr removeDelegate:self];
}

- (IBAction)backClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)peripheralDidConnect:(CBPeripheral *)peripheral {
    dispatch_async(dispatch_get_main_queue(), ^(void){
    });
}

- (void)peripheralDidDisconnect:(CBPeripheral *)peripheral {
    dispatch_async(dispatch_get_main_queue(), ^(void){
    });
}

//foodMassByUnit 对应秤体单位显示的值
//foodMassG 对秤秤体转换成g单位后的值
//sign 值对应的正负号
//stable 是否稳定
//unit 单位 unit==0 单位g, unit==1 单位lb:0z, unit==2 单位ml, unit==3 单位fl'oz, unit==4 单位ml, unit ==5 单位fl'oz
//unit==1,unit==3,unit==5,foodMassByUni的值扩大了10倍
- (void)peripheralDidReceived:(CBPeripheral *)peripheral data:(SSBLEReadWriteData *)data datas:(NSArray *)datas {
    NSDictionary *values = data.readValues;
    NSLog(@"%@", values);
    int stable = [[values objectForKey:@"stable"] intValue];
    _foodMassG = (double)[[values objectForKey:@"foodMassG"] intValue];
    _foodMassByUnit = (double)[[values objectForKey:@"foodMassByUnit"] intValue];
    _unit = [[values objectForKey:@"unit"] intValue];
    if (_unit == 1 || _unit == 3 || _unit == 5) {
        _foodMassByUnit = _foodMassByUnit / 10.0f;
    }
    int nagative = [[values objectForKey:@"sign"] intValue];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self.saveValueLabel.text = [NSString stringWithFormat:@"%@%.0f g", (nagative ? @"-" : @""), _foodMassG];
        self.stableLabel.text = (stable == 1 ? @"稳定" : @"不稳定");
        
        if (nagative == 1) {
            _foodMassG *= -1;
            _foodMassByUnit *= -1;
        }
        [self setDataWithFood:_selectFood foodMassG:_foodMassG foodMassByUnit:_foodMassByUnit unit:_unit];
    });
}

- (void)setDataWithFood:(Food *)food foodMassG:(double)foodMassG foodMassByUnit:(double)foodMassByUnit unit:(int)unit {
    [_eatFood reset];
    _eatFood.foodMassG = foodMassG;
    
    BOOL nagative = (foodMassG >= 0) ? NO : YES;
    double realFoodMassByUnit = fabs(foodMassByUnit);
    if (unit == 0) {
        if (realFoodMassByUnit < 1000.0f) {
            self.displayValueLabel.text = [NSString stringWithFormat:@"%@%.0f g", (nagative ? @"-" : @""), realFoodMassByUnit];
        } else {
            self.displayValueLabel.text = [NSString stringWithFormat:@"%@%.3f kg", (nagative ? @"-" : @""), realFoodMassByUnit / 1000.0f];
        }
    } else if (unit == 1) {
        double pounds = floor(realFoodMassByUnit / 16);;
        double oz = realFoodMassByUnit - pounds * 16;
        self.displayValueLabel.text = [NSString stringWithFormat:@"%@%.0f:%.1f lb:oz", (nagative ? @"-" : @""), pounds, oz];
    } else if (unit == 2) {
        self.displayValueLabel.text = [NSString stringWithFormat:@"%@%.0f ml", (nagative ? @"-" : @""), realFoodMassByUnit];
    } else if (unit == 3) {
        self.displayValueLabel.text = [NSString stringWithFormat:@"%@%.1f fl'oz", (nagative ? @"-" : @""), realFoodMassByUnit];
    } else if (unit == 4) {
        self.displayValueLabel.text = [NSString stringWithFormat:@"%@%.0f ml", (nagative ? @"-" : @""), realFoodMassByUnit];
    } else if (unit == 5) {
        self.displayValueLabel.text = [NSString stringWithFormat:@"%@%.1f fl'oz", (nagative ? @"-" : @""), realFoodMassByUnit];
    }
    
    if (food) {
        _eatFood.foodID = food.foodID;
        _eatFood.relateFood = food;
        _eatFood.energyConsumed = floor(_selectFood.energyConsumed * foodMassG / 10.0) / 10.0;
        _eatFood.protein = floor(_selectFood.protein * foodMassG) / 100.0;
        _eatFood.fatTotal = floor(_selectFood.fatTotal * foodMassG) / 100.0;
        _eatFood.carbohydrates = floor(_selectFood.carbohydrates * foodMassG) / 100.0;
        _eatFood.fiber = floor(_selectFood.fiber * foodMassG) / 100.0;
        _eatFood.cholesterol = floor(_selectFood.cholesterol * foodMassG / 100.0);
        _eatFood.sodium = floor(_selectFood.sodium * foodMassG / 100.0);
    }
    
    self.parametersLabel.text = [NSString stringWithFormat:@"this apple contains:\r\n\r\nenergy: %.1f kcal\r\nfatTotal: %.2f g\r\nprotein: %.2f g\r\nsodium: %.0f mg\r\ncarbohydrates: %.2f g\r\nfiber: %.2f g\r\ncholesterol: %.0f mg\r\n", _eatFood.energyConsumed, _eatFood.fatTotal, _eatFood.protein, _eatFood.sodium, _eatFood.carbohydrates, _eatFood.fiber, _eatFood.cholesterol];
}

@end
