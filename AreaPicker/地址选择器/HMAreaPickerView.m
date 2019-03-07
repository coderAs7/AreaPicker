#import "HMAreaPickerView.h"
//工具
#import "MJExtension.h"

typedef NS_ENUM(NSUInteger, HMComponentType) {
    HMComponentTypeProvince = 0, // 省
    HMComponentTypeCity,         // 市
    HMComponentTypeArea,         // 区
};

@interface HMAreaPickerView()<UIPickerViewDelegate, UIPickerViewDataSource>
/** 地址数据 */
@property (nonatomic, strong) NSArray *areaArray;
/** pickView */
@property (nonatomic, strong) UIPickerView *pickView;
/** 顶部视图 */
@property (nonatomic, strong) UIView *topView;
/** 取消按钮 */
@property (nonatomic, strong) UIButton *cancelButton;
/** 确定按钮 */
@property (nonatomic, strong) UIButton *sureButton;
@property (nonatomic, strong) UIButton *coverButton;

@property (nonatomic, strong) NSString *provinceIDOutSide;
@property (nonatomic, strong) NSString *cityIDOutSide;
@property (nonatomic, strong) NSString *areaIDOutSide;



//@property (nonatomic, assign) BOOL isHide;

@property (nonatomic, assign) CGRect pickViewFrame;
@end

static const CGFloat topViewHeight = 45;
static const CGFloat buttonWidth = 60;
static const CGFloat animationDuration = 0.3;


@implementation HMAreaPickerView
{
    NSInteger _provinceSelectedRow;
    NSInteger _citySelectedRow;
    NSInteger _areaSelectedRow;
    
    NSInteger _provinceSelectedRowOutSide;
    NSInteger _citySelectedRowOutSide;
    NSInteger _areaSelectedRowOutSide;
    
}

#pragma mark - - load

+ (instancetype)pickerViewWithFrame:(CGRect)frame{
    return [[self alloc]initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect) frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self init:frame];
        [self initSubviews];
    }
    return self;
}

#pragma mark - show,dismiss
- (void)showInView:(UIView *)view defaultProvinceID:(NSString *)PID defaultCityID:(NSString *)CID defaultAreaID:(NSString *)AID completeBlock:(void (^)(void))completion{
    [self prepareDataWithDefaultProvinceID:PID defaultCityID:CID defaultAreaID:AID completeBlock:^{
        [self innerShowInView:view andCompleteBlock:completion];
    }];
}
- (void)innerShowInView:(UIView *)view andCompleteBlock:(void (^)(void))completion{
    _provinceSelectedRow = _provinceSelectedRowOutSide;
    _citySelectedRow = _citySelectedRowOutSide;
    _areaSelectedRow = _areaSelectedRowOutSide;
    
    [self.pickView reloadAllComponents];
    
    
    [self.pickView selectRow:_provinceSelectedRowOutSide inComponent:0 animated:NO];
    [self.pickView selectRow:_citySelectedRowOutSide inComponent:1 animated:NO];
    [self.pickView selectRow:_areaSelectedRowOutSide inComponent:2 animated:NO];
    
    self.topView.userInteractionEnabled = NO;
    self.coverButton.userInteractionEnabled = NO;
    self.pickView.userInteractionEnabled = NO;
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    
    self.frame = bounds;
    self.coverButton.frame = bounds;
    
    _topView.frame = CGRectMake(0, bounds.size.height, bounds.size.width, topViewHeight);
    
    _pickView.frame = CGRectMake(0, CGRectGetMaxY(_topView.frame), bounds.size.width, _pickViewFrame.size.height);
    
    [view addSubview:self];
    [UIView animateWithDuration:animationDuration animations:^{
        CGRect tempRect = self.topView.frame;
        tempRect.origin.y = bounds.size.height - topViewHeight - self.pickViewFrame.size.height;
        self.topView.frame = tempRect;
        tempRect = self.pickViewFrame;
        tempRect.origin.y = CGRectGetMaxY(self.topView.frame);
        self.pickView.frame = tempRect;
    }completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
        
        self.topView.userInteractionEnabled = YES;
        self.coverButton.userInteractionEnabled = YES;
        self.pickView.userInteractionEnabled = YES;
    }];
}
- (void)prepareDataWithDefaultProvinceID:(NSString *)PID defaultCityID:(NSString *)CID defaultAreaID:(NSString *)AID completeBlock:(void (^)(void))completion{
    
    BOOL didLoadAddressData = self.areaArray != nil;
    
    
    BOOL isEqual = [_provinceIDOutSide isEqualToString:PID];
    BOOL isAllNil = _provinceIDOutSide.length == 0 && PID.length == 0;
    
    BOOL provinceIsEqual = (isEqual || isAllNil);
    
    isEqual = [_cityIDOutSide isEqualToString:CID];
    isAllNil = _cityIDOutSide.length == 0 && CID.length == 0;
    BOOL cityIsEqual = (isEqual || isAllNil);
    
    isEqual = [_areaIDOutSide isEqualToString:AID];
    isAllNil = _areaIDOutSide.length == 0 && AID.length == 0;
    BOOL areaIsEqual = (isEqual || isAllNil);
    
    BOOL isPositionEqual = (provinceIsEqual && cityIsEqual && areaIsEqual);
    
    if (didLoadAddressData && isPositionEqual) {
        !completion? :completion();
        return;
    }
    
    !self.beginLoadAddressDataBlock? :self.beginLoadAddressDataBlock();
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (didLoadAddressData == NO) {
            [self loadData];
        }
        if (isPositionEqual == NO) {
            [self getDefaultRowWithDefaultProvinceID:PID defaultCityID:CID defaultAreaID:AID];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            !self.loadAddressDataSuccessBlock? :self.loadAddressDataSuccessBlock();
            if (completion) {
                completion();
            }
        });
    });
}


- (void)getDefaultRowWithDefaultProvinceID:(NSString *)PID defaultCityID:(NSString *)CID defaultAreaID:(NSString *)AID{
    
    _provinceSelectedRowOutSide = 0;
    _citySelectedRowOutSide = 0;
    _areaSelectedRowOutSide = 0;
    
    NSInteger PCount = self.areaArray.count;
    HMCityAddressModel *pModel;
    for (NSInteger i = 0; i < PCount; i++) {
        pModel = self.areaArray[i];
        if ([PID isEqualToString:pModel.ID]) {
            _provinceSelectedRowOutSide = i;
            break;
        }
    }
    NSInteger CCount = pModel.cl_city.count;
    HMCityAddressModel *CModel;
    if (CCount) {
        for (NSInteger i = 0; i < CCount; i++) {
            CModel = pModel.cl_city[i];
            if ([CID isEqualToString:CModel.ID]) {
                _citySelectedRowOutSide = i;
                break;
            }
        }
    }
    
    NSInteger ACount = CModel.cl_city.count;
    HMCityAddressModel *AModel;
    if (ACount) {
        for (NSInteger i = 0; i < ACount; i++) {
            AModel = CModel.cl_city[i];
            if ([AID isEqualToString:AModel.ID]) {
                _areaSelectedRowOutSide = i;
                break;
            }
        }
    }
}
#pragma mark - - Button Action
- (void)cancelButtonClicked:(UIButton *)sender{
    
    if (self.pickViewDelegate &&
        [self.pickViewDelegate respondsToSelector:@selector(cancelButtonClicked)]) {
        [self.pickViewDelegate cancelButtonClicked];
    }
    [self dismiss];
}

- (void)sureButtonClicked:(UIButton *)sender{
    
    HMCityAddressModel *Province;
    HMCityAddressModel *city;
    HMCityAddressModel *Area;
    
    _provinceIDOutSide = nil;
    _cityIDOutSide = nil;
    _areaIDOutSide = nil;
    
    // 这里记录一下用户主动选择的数据,如果用户每点击确认,那么这个数据是不记录的
    _provinceSelectedRowOutSide = _provinceSelectedRow;
    _citySelectedRowOutSide = _citySelectedRow;
    _areaSelectedRowOutSide = _areaSelectedRow;
    
    
    if (_provinceSelectedRow < _areaArray.count) {
        Province = _areaArray[_provinceSelectedRowOutSide];
        _provinceIDOutSide = Province.ID;
    }
    if (_citySelectedRow < Province.cl_city.count) {
        city = Province.cl_city[_citySelectedRowOutSide];
        _cityIDOutSide = city.ID;
    }
    if (_areaSelectedRow < city.cl_city.count) {
        Area = city.cl_city[_areaSelectedRowOutSide];
        _areaIDOutSide = Area.ID;
    }

    if ([self.pickViewDelegate respondsToSelector:@selector(selectedAreaResultWithProvinceModel:cityModel:areaModel:)]) {
        [self.pickViewDelegate selectedAreaResultWithProvinceModel:Province cityModel:city areaModel:Area];
    }
    [self dismiss];
}

#pragma mark - - UIPickerViewDelegate,UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (component) {
        case HMComponentTypeProvince:
            return _areaArray.count;
            break;
        case HMComponentTypeCity:{
            HMCityAddressModel *city = _areaArray[_provinceSelectedRow];
            return city.cl_city.count;
        }
            break;
        case HMComponentTypeArea:
        {
            HMCityAddressModel *city = _areaArray[_provinceSelectedRow];
            HMCityAddressModel *area = city.cl_city[_citySelectedRow];
            return area.cl_city.count;
        }
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    switch (component) {
        case HMComponentTypeProvince:
        {
            HMCityAddressModel *Province = _areaArray[row];
            return Province.cl_Name;
        }
            break;
        case HMComponentTypeCity:
        {
            HMCityAddressModel *Province = _areaArray[_provinceSelectedRow];
            if (row < Province.cl_city.count) {
                HMCityAddressModel *city = Province.cl_city[row];
                return city.cl_Name;
            }else{
                return nil;
            }

        }
            break;
        case HMComponentTypeArea:
        {
            HMCityAddressModel *Province = _areaArray[_provinceSelectedRow];
            HMCityAddressModel *city = Province.cl_city[_citySelectedRow];
            if (row < city.cl_city.count) {
                HMCityAddressModel *area = city.cl_city[row];
                return area.cl_Name;
            }else{
                return nil;
            }

        }
        default:
            return nil;
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch (component) {
        case HMComponentTypeProvince:{
            _provinceSelectedRow = row;
            _citySelectedRow = 0;
            _areaSelectedRow = 0;
            [pickerView selectRow:0 inComponent:1 animated:NO];
            [pickerView selectRow:0 inComponent:2 animated:NO];
            break;
        }
        case HMComponentTypeCity:{
            _citySelectedRow = row;
            _areaSelectedRow = 0;
            [pickerView selectRow:0 inComponent:2 animated:NO];
            break;
        }
        case HMComponentTypeArea:
            _areaSelectedRow = row;
            break;
        default:
            _provinceSelectedRow = row;
            break;
    }
    [pickerView reloadAllComponents];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:_titleFont ? _titleFont : [UIFont boldSystemFontOfSize:14]];
    }
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}
- (void)dismiss{
    self.topView.userInteractionEnabled = NO;
    self.coverButton.userInteractionEnabled = NO;
    self.pickView.userInteractionEnabled = NO;
    [UIView animateWithDuration:animationDuration animations:^{
        CGRect tempRect = self.topView.frame;
        tempRect.origin.y = [[UIScreen mainScreen] bounds].size.height;
        self.topView.frame = tempRect;
        tempRect = self.pickViewFrame;
        tempRect.origin.y = CGRectGetMaxY(self.topView.frame);
        self.pickView.frame = tempRect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
        self.topView.userInteractionEnabled = YES;
        self.coverButton.userInteractionEnabled = YES;
        self.pickView.userInteractionEnabled = YES;
    }];
}

- (void)loadData{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"json"];
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    // 对数据进行JSON格式化并返回字典形式
    NSArray *resultArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    _areaArray = [HMCityAddressModel mj_objectArrayWithKeyValuesArray:resultArray];
}
/** 初始化子视图 */
- (void)initSubviews{
    [self addSubview:self.coverButton];
    [self addSubview:self.topView];
    [self addSubview:self.pickView];
    [self.topView addSubview:self.cancelButton];
    [self.topView addSubview:self.sureButton];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan)];
    [self addGestureRecognizer:pan];
}
- (void)pan{
    
}
/** 初始化数据 */
- (void)init:(CGRect)frame{
    _pickViewFrame = frame;
    
    self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    _provinceSelectedRow = 0;
    _citySelectedRow = 0;
    _areaSelectedRow = 0;
}

#pragma mark - - get
- (UIPickerView *)pickView{
    if (!_pickView) {
        _pickView = [[UIPickerView alloc] init];
        _pickView.dataSource = self;
        _pickView.delegate = self;
        _pickView.showsSelectionIndicator = NO;
        _pickView.backgroundColor = [UIColor whiteColor];
    }
    return _pickView;
}

- (UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc] init];
        UIView *line = [UIView new];
        line.frame = CGRectMake(0, topViewHeight - 1, [[UIScreen mainScreen] bounds].size.width, 1.0 / [UIScreen mainScreen].scale);
        line.backgroundColor = [UIColor lightGrayColor];
        [_topView addSubview:line];
        _topView.backgroundColor = [UIColor whiteColor];
    }
    return _topView;
}

- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(0, 0, buttonWidth, topViewHeight);
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor colorWithRed:183/255.0 green:49/255.0 blue:33/255.0 alpha:1] forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)sureButton{
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureButton.frame = CGRectMake(self.frame.size.width - buttonWidth, 0, buttonWidth, topViewHeight);
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_sureButton setTitleColor:[UIColor colorWithRed:183/255.0 green:49/255.0 blue:33/255.0 alpha:1] forState:UIControlStateNormal];
        [_sureButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_sureButton addTarget:self action:@selector(sureButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}

- (UIButton *)coverButton{
    if (!_coverButton) {
        _coverButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _coverButton.backgroundColor = [UIColor clearColor];
        [_coverButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _coverButton;
}

#pragma mark - - set
- (void)setPickViewBackgroundColor:(UIColor *)pickViewBackgroundColor{
    self.pickView.backgroundColor = pickViewBackgroundColor;
}

- (void)setTopViewBackgroundColor:(UIColor *)topViewBackgroundColor{
    self.topView.backgroundColor = topViewBackgroundColor;
}

- (void)setCancelButtonColor:(UIColor *)cancelButtonColor{
    [self.cancelButton setTitleColor:cancelButtonColor forState:UIControlStateNormal];
}

- (void)setSureButtonColor:(UIColor *)sureButtonColor{
    [self.sureButton setTitleColor:sureButtonColor forState:UIControlStateNormal];
}
@end
