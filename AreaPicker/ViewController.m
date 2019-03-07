

#import "ViewController.h"
#import "HMAreaPickerView.h"
@interface ViewController ()<HMPickerViewDelegate>

@property (nonatomic, strong) HMAreaPickerView *pickView;
@property (nonatomic, strong) UITextField *f1;
@property (nonatomic, strong) UITextField *f2;
@property (nonatomic, strong) UITextField *f3;

@property (nonatomic, strong) HMCityAddressModel *m1;
@property (nonatomic, strong) HMCityAddressModel *m2;
@property (nonatomic, strong) HMCityAddressModel *m3;

@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    _f1 = [[UITextField alloc] initWithFrame:CGRectMake(100, 100, 200, 40)];
    _f2 = [[UITextField alloc] initWithFrame:CGRectMake(100, 160, 200, 40)];
    _f3 = [[UITextField alloc] initWithFrame:CGRectMake(100, 220, 200, 40)];
    
    _f1.placeholder = @"省";
    _f2.placeholder = @"市";
    _f3.placeholder = @"区";
    
    _f1.font = [UIFont systemFontOfSize:30];
    _f2.font = [UIFont systemFontOfSize:30];
    _f3.font = [UIFont systemFontOfSize:30];
    
    [self.view addSubview:_f1];
    [self.view addSubview:_f2];
    [self.view addSubview:_f3];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_pickView == nil) {
        _pickView = [[HMAreaPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 285)];
        _pickView.pickViewDelegate = self;
    }


    
    [_pickView showInView:self.view defaultProvinceID:_m1.ID defaultCityID:_m2.ID defaultAreaID:_m3.ID completeBlock:nil];
    
    
}


// 确定按钮点击回调
- (void)selectedAreaResultWithProvinceModel:(HMCityAddressModel *)modelP
                                  cityModel:(HMCityAddressModel *)modelC
                                  areaModel:(HMCityAddressModel *)modelA{
    _f1.text = modelP.cl_Name;
    _f2.text = modelC.cl_Name;
    _f3.text = modelA.cl_Name;
    
    _m1 = modelP;
    _m2 = modelC;
    _m3 = modelA;
}
@end
