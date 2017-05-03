#import <UIKit/UIKit.h>


@interface FatProController : UIViewController


@property (nonatomic, assign) int deviceType;
@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, copy) NSString *advertiseName;
@property (nonatomic, copy) NSString *serialNO;


@property (nonatomic, assign) IBOutlet UILabel *lblWeightKg;
@property (nonatomic, assign) IBOutlet UILabel *lblWeightlb;
@property (nonatomic, assign) IBOutlet UILabel *lblStable;


@property (nonatomic, assign) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) IBOutlet UILabel *lblTestFat;


- (IBAction)backClick:(id)sender;
- (IBAction)testFat:(id)sender;
- (IBAction)testFat2:(id)sender;

@end
