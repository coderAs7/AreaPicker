#import <UIKit/UIKit.h>
#import "HMCityAddressModel.h"
@class HMAreaPickerView;
@protocol HMPickerViewDelegate <NSObject>

@optional

// 确定按钮点击回调
- (void)selectedAreaResultWithProvinceModel:(HMCityAddressModel *)modelP
                                  cityModel:(HMCityAddressModel *)modelC
                                  areaModel:(HMCityAddressModel *)modelA;

// 取消按钮点击回调
- (void)cancelButtonClicked;
@end

@interface HMAreaPickerView : UIView
/** 标题大小 */
@property (nonatomic, strong) UIFont  *titleFont;
/** 选择器背景颜色 */
@property (nonatomic, strong) UIColor *pickViewBackgroundColor;
/** 选择器头部视图颜色 */
@property (nonatomic, strong) UIColor *topViewBackgroundColor;
/** 取消按钮颜色 */
@property (nonatomic, strong) UIColor *cancelButtonColor;
/** 确定按钮颜色 */
@property (nonatomic, strong) UIColor *sureButtonColor;

@property(nonatomic,strong) void(^beginLoadAddressDataBlock)(void);
@property(nonatomic,strong) void(^loadAddressDataSuccessBlock)(void);

/** 选择器代理 */
@property (nonatomic, weak) id<HMPickerViewDelegate> pickViewDelegate;

+ (instancetype)pickerViewWithFrame:(CGRect)frame;

- (void)showInView:(UIView *)view defaultProvinceID:(NSString *)PID defaultCityID:(NSString *)CID defaultAreaID:(NSString *)AID completeBlock:(void (^)(void))completion;



@end
