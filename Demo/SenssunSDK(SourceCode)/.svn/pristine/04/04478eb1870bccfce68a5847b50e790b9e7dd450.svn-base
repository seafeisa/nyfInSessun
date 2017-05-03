#import <Foundation/Foundation.h>


typedef NS_ENUM(int, DeviceSportModeEnum) {
    DeviceSportMode1 = 1,//无运动人士
    DeviceSportMode2 = 2,//办公室人士
    DeviceSportMode3 = 3,//常站立人士
    DeviceSportMode4 = 4,//从事体力劳动人士
    DeviceSportMode5 = 5,//运动员
};


typedef NS_ENUM(NSInteger, DeviceGenderEnum) {
    DeviceGenderFemale = 0,//女
    DeviceGenderMale = 1//男
};


typedef NS_ENUM(int, DataTypeEnum) {
    DataTypeNone = -1,
    DataTypeWeigh = 0,//秤重数据
    DataTypeTestFat = 1,//测试脂肪数据
    DataTypeHistory = 2,//历史数据
    DataTypeReplyTestFat = 3,//测试脂肪命令发送成功
    DataTypeReplySearchHistory = 4,//查询历史数据发送成功
    DataTypeHeartRate = 5,//心率数据
    DataTypeTestFatError = 6//测试脂肪无效
};


@interface BodyMeasure : NSObject

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, assign) int deviceType;

//表示数据类型
@property (nonatomic, assign) DataTypeEnum dataType;

//表示体重数据，单位kg, 10times, 初始化值为－1
@property (nonatomic, assign) int bodyMassKG;

//表示体重数据，单位lb, 10times, 初始化值为－1
@property (nonatomic, assign) int bodyMassLB;

//表示体重数据 YES－稳定，NO－不稳定
@property (nonatomic, assign) BOOL ifStable;

//表示当前秤体显示的体重数据单位
@property (nonatomic, copy) NSString *unitID;

//表示秤体用户序号，数值范围1～12, 初始化值为－1
@property (nonatomic, assign) int deviceUserID;

//表示用户性别，0=女性，1=男性, 初始化值为－1
@property (nonatomic, assign) int biologicalSexID;

//表示用户年龄，数值范围10-100, 初始化值为－1
@property (nonatomic, assign) int age;

//表示用户身高，单位厘米, 初始化值为－1
@property (nonatomic, assign) int heightCM;

//表示用户身高，单位英寸, 10times, 初始化值为－1
@property (nonatomic, assign) int heightIN;

//表示历史数据序号，数值范围1～20, 初始化值为－1
@property (nonatomic, assign) int number;

//表示历史数据记录日期，格式yyyy-MM-dd
@property (nonatomic, copy) NSString *recordDate;

//表示历史数据记录日期的当天的总秒数, 初始化值为－1
@property (nonatomic, assign) int dayInterval;

//表示体质指数，初始化值为－1
@property (nonatomic, assign) int bodyMassIndex;

//表示脂肪率，当设备为脂肪秤时显示(单位％, 1000times), 初始化值为－1
//表示脂肪率，当设备为八电极时显示(单位％, 1000times), 初始化值为－1
@property (nonatomic, assign) int bodyFatPercentage;

//表示水分值，当设备为脂肪秤时显示(单位％, 1000times), 初始化值为－1
//表示水分值，当设备为八电极时显示(单位kg, 10times)，初始化值为－1
@property (nonatomic, assign) int hydro;

//表示肌肉值，当设备为脂肪秤时显示(单位％, 1000times), 初始化值为－1
//表示肌肉值，当设备为八电极时显示(单位kg, 10times)，初始化值为－1
@property (nonatomic, assign) int muscle;

//表示骨骼值，当设备为脂肪秤时显示(单位％, 1000times), 初始化值为－1
//表示骨骼值，当设备为八电极时显示(单位kg, 10times), 初始化值为－1
@property (nonatomic, assign) int bone;

//表示基础代谢＋普通活动所需要的能量，当设备为脂肪秤时显示(单位kcal), 初始化值为－1
//表示基础代谢，当设备为八电极时显示(单位kcal), 初始化值为－1
@property (nonatomic, assign) int kcal;

//表示蛋白质，当设备为脂肪秤时显示(单位％, 1000times), 初始化值为－1
//表示蛋白质，当设备为八电极时，当设备为八电极时显示(单位kg, 1000times), 初始化值为－1
@property (nonatomic, assign) int protein;

//表示内脏脂肪，当设备为脂肪秤时显示(单位％, 1000times), 初始化值为－1；
//表示内脏脂肪指数, 当设备为八电极时，显示(10times), 初始化值为－1
@property (nonatomic, assign) int visceralFat;

//表示水分，当设备为八电极时显示(单位kg, 10times), 初始化值为－1
@property (nonatomic, assign) int cellHydro;

//表示瘦体重，当设备为八电极时显示(单位kg, 10times), 初始化值为－1
@property (nonatomic, assign) int leanBodyMass;

//表示身体年龄，当设备为八电极时显示, 初始化值为－1
@property (nonatomic, assign) int bodyAge;

//表示健康得分，当设备为八电极时显示, 初始化值为－1
@property (nonatomic, assign) int healthScore;

//表示体重超出测量范围，成长秤使用
@property (nonatomic, assign) BOOL overLoad;

//表示皮下脂肪，当设备为脂肪秤时显示(单位％, 1000times), 初始化值为－1
@property (nonatomic, assign) int bcutaneousFat;

@property (nonatomic, assign) int heartRate;
@property (nonatomic, assign) int hco;
@property (nonatomic, assign) int hci;
@property (nonatomic, assign) int tpr;
@property (nonatomic, assign) int hac;


- (id)copy;

//计算活动代谢
//bmr表示变量［kcal］的值
//sportMode表示运动量，共5个级别，由SportModeEnum指示范围值
//biologicalSexID表示性别，由GenderEnum指示范围值
+ (int)getAMR:(int)bmr :(int)sportMode :(int)biologicalSexID;

@end
