#import "HideImGui.h"

@implementation HideImGui

- (instancetype)init {
    self = [super init];
    if (self) {
        [self 启动过直播];
    };
    return self;
};

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self 启动过直播];
    };
    return self;
};

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self 启动过直播];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self._UITextField.frame = self.bounds;
    self._UIView.frame = self.bounds;
}

-(void)启动过直播 {
    [self addSubview:self._UITextField];
    self._UITextField.subviews.firstObject.userInteractionEnabled = YES;
    [self._UITextField.subviews.firstObject addSubview:self._UIView];
};

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    if (self._UITextField != view) {
        [self._UIView addSubview:view];
    };
};

- (UITextField*)_UITextField{
    if (!__UITextField) {
        __UITextField = [[UITextField alloc] init];
        __UITextField.secureTextEntry = YES;
    };
    return __UITextField;
};

- (UIView *)_UIView {
    __UIView.userInteractionEnabled = YES;
    if (!__UIView) {
        __UIView = [[UIView alloc] init];
    };
    return __UIView;
};

@end
