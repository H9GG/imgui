#import "HUDRootViewController.h"

#import "JianHei.h"

#import "Memory.h"
#import "DataType.h"
#import "ShadowTrackerExt.h"
#import "HideImGui.h"

#import <MetalKit/MetalKit.h>


@interface HUDRootViewController () <MTKViewDelegate>
@property (nonatomic, strong) MTKView* _MTKView;
@property (nonatomic, strong) id <MTLCommandQueue> _MTLCommandQueue;
@end

@implementation HUDRootViewController

static float 宽度;
static float 高度;

static long 模块地址;
static long LWorld;
static long LGName;

static NSArray* 玩家数组;
static NSArray* 物资箱和死亡盒数组;
static NSArray* 物资数组;

static 本地玩家信息 本地玩家信息数组;
static NSArray* 玩家信息数组;
static NSArray* 玩家绘制信息数组;

static NSArray* 物资箱和死亡盒信息数组;
static NSArray* 物资信息数组;
// static NSArray* 物资箱和死亡盒列表信息数组;
static bool 是否显示物资 = false;
static bool 是否显示物资缓冲 = false;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;
    self._MTKView = [[MTKView alloc] initWithFrame:self.view.bounds];
    self._MTKView.device = MTLCreateSystemDefaultDevice();
    self._MTKView.opaque = NO;
    self._MTKView.backgroundColor = UIColor.clearColor;
    self._MTKView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self._MTKView.delegate = self;
    
    HideImGui* _HideImGui = [[HideImGui alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [_HideImGui setUserInteractionEnabled:NO];
    [_HideImGui addSubview:self._MTKView];
    [self.view addSubview:_HideImGui];
    
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGui::StyleColorsDark();
    
    ImGuiIO& _ImGuiIO = ImGui::GetIO();
    ImFontConfig _ImFontConfig;
    _ImFontConfig.FontDataOwnedByAtlas = true;
    _ImGuiIO.Fonts->AddFontFromMemoryTTF((void*)JianHei, JianHei_len, 26.0f, &_ImFontConfig, _ImGuiIO.Fonts->GetGlyphRangesChineseFull());

    ImGui_ImplMetal_Init(self._MTKView.device);
    self._MTLCommandQueue = [self._MTKView.device newCommandQueue];
    
    pid_t 进程ID = 获取进程ID(@"ShadowTrackerExt");
    模块地址 = 获取模块地址(进程ID, @"ShadowTrackerExtra");
    
    NSThread* 对象数组线程 = [[NSThread alloc] initWithTarget:self selector:@selector(获取对象数组) object:nil];
    [对象数组线程 start];
    NSThread* 玩家信息线程 = [[NSThread alloc] initWithTarget:self selector:@selector(获取玩家信息) object:nil];
    [玩家信息线程 start];
    NSThread* 玩家绘制信息线程 = [[NSThread alloc] initWithTarget:self selector:@selector(获取玩家绘制信息) object:nil];
    [玩家绘制信息线程 start];
    NSThread* 物资箱和死亡盒信息线程 = [[NSThread alloc] initWithTarget:self selector:@selector(获取物资箱和死亡盒信息) object:nil];
    [物资箱和死亡盒信息线程 start];
    
};

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    
};

//if ([GName字符 containsString:@"BPPawn_Escape_Wolf_C"]) {
//    GName字符 = [NSString stringWithFormat:@"狐狸(%.fm)", 临时物资信息.F物资距离];
//} else if ([GName字符 containsString:@"BPPawn_Escape_Raven_C"]) {
//    GName字符 = [NSString stringWithFormat:@"乌鸦(%.fm)", 临时物资信息.F物资距离];
//} else if ([GName字符 containsString:@"BPPawn_Escape_RobocopDog_Solo_C"]) {
//    GName字符 = [NSString stringWithFormat:@"机械狗(%.fm)", 临时物资信息.F物资距离];
//};

- (void)drawInMTKView:(nonnull MTKView *)view {
    ImGuiIO& _ImGuiIO = ImGui::GetIO();
    
    float 像素比例 = view.window.screen.scale ?: UIScreen.mainScreen.scale;
    宽度 = view.bounds.size.width * 像素比例;
    高度 = view.bounds.size.height * 像素比例;
    _ImGuiIO.DisplaySize = ImVec2(宽度, 高度);
    _ImGuiIO.DisplayFramebufferScale = ImVec2(1, 1);
    _ImGuiIO.DeltaTime = 1.0f / 90.0f;
    id<MTLCommandBuffer> _MTLCommandBuffer = [self._MTLCommandQueue commandBuffer];
    MTLRenderPassDescriptor* _MTLRenderPassDescriptor = view.currentRenderPassDescriptor;
    if (_MTLRenderPassDescriptor == nil) { [_MTLCommandBuffer commit]; return; }
    ImGui_ImplMetal_NewFrame(_MTLRenderPassDescriptor);
    ImGui::NewFrame();
    ImDrawList* _ImDrawList = ImGui::GetForegroundDrawList();
    
    LWorld = 读取<long>(模块地址 + GWorld);
    LGName = 读取<long>(模块地址 + GName);
    
    if (!无效地址判断(LWorld)) {
        long LNetDriver = 读取<long>(LWorld + NetDriver);
        if (!无效地址判断(LNetDriver)) {
            long LServerConnection = 读取<long>(LNetDriver + ServerConnection);
            if (!无效地址判断(LServerConnection)) {
                long LPlayerController = 读取<long>(LServerConnection + PlayerController);
                if (!无效地址判断(LPlayerController)) {
                    本地玩家信息数组.LPawn = 读取<long>(LPlayerController + Pawn);
                    本地玩家信息数组.ITeamID = 读取<int>(LPlayerController + PlayerControllerTeamID);
                    本地玩家信息数组.IbFreeCamera = 读取<int>(LPlayerController + bFreeCamera);
                    
                    long LPlayerCameraManager = 读取<long>(LPlayerController + PlayerCameraManager);
                    if (!无效地址判断(LPlayerCameraManager)) {
                        本地玩家信息数组.MMinimalViewInfo = [self 获取MinimalViewInfo:LPlayerCameraManager + ViewTarget + POV];
                        本地玩家信息数组.RRotation矩阵 = [self 获取Rotation矩阵:本地玩家信息数组.MMinimalViewInfo.RRotation];
                        
                        
                        long LSTExtraBaseCharacter = 读取<long>(LPlayerController + STExtraBaseCharacter);
                        if (!无效地址判断(LSTExtraBaseCharacter)) {
                            long LWeaponManagerComponent = 读取<long>(LSTExtraBaseCharacter + WeaponManagerComponent);
                            if (!无效地址判断(LWeaponManagerComponent)) {
                                long LCurrentWeaponReplicated = 读取<long>(LWeaponManagerComponent + CurrentWeaponReplicated);
                                if (!无效地址判断(LCurrentWeaponReplicated)) {
                                    long LCachedBulletTrackComponent = 读取<long>(LCurrentWeaponReplicated + CachedBulletTrackComponent);
                                    if (!无效地址判断(LCachedBulletTrackComponent)) {
                                        写入(LCachedBulletTrackComponent + CurRecoilValue, -1.0f);
                                        写入(LCachedBulletTrackComponent + VerticalRecoilTarget, -1.0f);
                                    };
                                };
                            };
                        };
                    };
                };
            };
        };
    };
    
    int 玩家人数 = 0;
    int 人机人数 = 0;
    
    if (!无效地址判断(本地玩家信息数组.LPawn)) {
        
        for (NSValue* Value in 玩家绘制信息数组) {
            玩家绘制信息 临时玩家绘制信息;
            [Value getValue:&临时玩家绘制信息];
            
            if (临时玩家绘制信息.IbIsAI) { 人机人数++; } else { 玩家人数++; };
            
            if (临时玩家绘制信息.是否在屏幕内) {
                NSString* 玩家名称字符 = [self 获取玩家名称:临时玩家绘制信息.LPlayerName];
                if (!临时玩家绘制信息.IbIsAI) 玩家名称字符 = [NSString stringWithFormat:@"(%d) %@", 临时玩家绘制信息.ITeamID, 玩家名称字符];
                ImVec2 玩家名称字符长度 = ImGui::CalcTextSize([玩家名称字符 UTF8String]);
                [self 绘制文字:_ImDrawList 字符:玩家名称字符 字体大小:12.0f 位置:ImVec2(临时玩家绘制信息.屏幕ImVec4.x - 玩家名称字符长度.x / 4.0f, 临时玩家绘制信息.屏幕ImVec4.y - 25.0f) 颜色:IM_COL32(255, 255, 0, 255)];
                
                _ImDrawList->AddRectFilled(ImVec2(临时玩家绘制信息.屏幕ImVec4.x - 40.0f, 临时玩家绘制信息.屏幕ImVec4.y - 10.0f), ImVec2(临时玩家绘制信息.屏幕ImVec4.x - 40.0f + 临时玩家绘制信息.百分比血量 / 1.25f, 临时玩家绘制信息.屏幕ImVec4.y - 5.0f), 临时玩家绘制信息.IbIsAI ? IM_COL32(0, 255, 0, 255) : IM_COL32(255, 0, 0, 255));
                
                _ImDrawList->AddRect(ImVec2(临时玩家绘制信息.屏幕ImVec4.x - 40.0f, 临时玩家绘制信息.屏幕ImVec4.y - 10.0f), ImVec2(临时玩家绘制信息.屏幕ImVec4.x + 40.0f, 临时玩家绘制信息.屏幕ImVec4.y - 5.0f), IM_COL32_BLACK);
                _ImDrawList->AddLine(ImVec2(临时玩家绘制信息.屏幕ImVec4.x - 24.0f, 临时玩家绘制信息.屏幕ImVec4.y - 10.0f), ImVec2(临时玩家绘制信息.屏幕ImVec4.x - 24.0f, 临时玩家绘制信息.屏幕ImVec4.y - 5.0f),  IM_COL32_BLACK, 1.0f);
                _ImDrawList->AddLine(ImVec2(临时玩家绘制信息.屏幕ImVec4.x - 8.0f, 临时玩家绘制信息.屏幕ImVec4.y - 10.0f), ImVec2(临时玩家绘制信息.屏幕ImVec4.x - 8.0f, 临时玩家绘制信息.屏幕ImVec4.y - 5.0f),  IM_COL32_BLACK, 1.0f);
                _ImDrawList->AddLine(ImVec2(临时玩家绘制信息.屏幕ImVec4.x + 8.0f, 临时玩家绘制信息.屏幕ImVec4.y - 10.0f), ImVec2(临时玩家绘制信息.屏幕ImVec4.x + 8.0f, 临时玩家绘制信息.屏幕ImVec4.y - 5.0f),  IM_COL32_BLACK, 1.0f);
                _ImDrawList->AddLine(ImVec2(临时玩家绘制信息.屏幕ImVec4.x + 24.0f, 临时玩家绘制信息.屏幕ImVec4.y - 10.0f), ImVec2(临时玩家绘制信息.屏幕ImVec4.x + 24.0f, 临时玩家绘制信息.屏幕ImVec4.y - 5.0f),  IM_COL32_BLACK, 1.0f);
                
                _ImDrawList->AddLine(ImVec2(临时玩家绘制信息.头部屏幕ImVec2.x, 临时玩家绘制信息.头部屏幕ImVec2.y), ImVec2(临时玩家绘制信息.脖子屏幕ImVec2.x, 临时玩家绘制信息.脖子屏幕ImVec2.y), 临时玩家绘制信息.IbIsAI ? IM_COL32(0, 255, 0, 255) : IM_COL32(255, 0, 0, 255), 1.0f);
                
                _ImDrawList->AddLine(ImVec2(临时玩家绘制信息.脖子屏幕ImVec2.x, 临时玩家绘制信息.脖子屏幕ImVec2.y), ImVec2(临时玩家绘制信息.左肩屏幕ImVec2.x, 临时玩家绘制信息.左肩屏幕ImVec2.y), 临时玩家绘制信息.IbIsAI ? IM_COL32(0, 255, 0, 255) : IM_COL32(255, 0, 0, 255), 1.0f);
                _ImDrawList->AddLine(ImVec2(临时玩家绘制信息.左肩屏幕ImVec2.x, 临时玩家绘制信息.左肩屏幕ImVec2.y), ImVec2(临时玩家绘制信息.左肘屏幕ImVec2.x, 临时玩家绘制信息.左肘屏幕ImVec2.y), 临时玩家绘制信息.IbIsAI ? IM_COL32(0, 255, 0, 255) : IM_COL32(255, 0, 0, 255), 1.0f);
                _ImDrawList->AddLine(ImVec2(临时玩家绘制信息.左肘屏幕ImVec2.x, 临时玩家绘制信息.左肘屏幕ImVec2.y), ImVec2(临时玩家绘制信息.左手屏幕ImVec2.x, 临时玩家绘制信息.左手屏幕ImVec2.y), 临时玩家绘制信息.IbIsAI ? IM_COL32(0, 255, 0, 255) : IM_COL32(255, 0, 0, 255), 1.0f);
                
                _ImDrawList->AddLine(ImVec2(临时玩家绘制信息.脖子屏幕ImVec2.x, 临时玩家绘制信息.脖子屏幕ImVec2.y), ImVec2(临时玩家绘制信息.右肩屏幕ImVec2.x, 临时玩家绘制信息.右肩屏幕ImVec2.y), 临时玩家绘制信息.IbIsAI ? IM_COL32(0, 255, 0, 255) : IM_COL32(255, 0, 0, 255), 1.0f);
                _ImDrawList->AddLine(ImVec2(临时玩家绘制信息.右肩屏幕ImVec2.x, 临时玩家绘制信息.右肩屏幕ImVec2.y), ImVec2(临时玩家绘制信息.右肘屏幕ImVec2.x, 临时玩家绘制信息.右肘屏幕ImVec2.y), 临时玩家绘制信息.IbIsAI ? IM_COL32(0, 255, 0, 255) : IM_COL32(255, 0, 0, 255), 1.0f);
                _ImDrawList->AddLine(ImVec2(临时玩家绘制信息.右肘屏幕ImVec2.x, 临时玩家绘制信息.右肘屏幕ImVec2.y), ImVec2(临时玩家绘制信息.右手屏幕ImVec2.x, 临时玩家绘制信息.右手屏幕ImVec2.y), 临时玩家绘制信息.IbIsAI ? IM_COL32(0, 255, 0, 255) : IM_COL32(255, 0, 0, 255), 1.0f);
                
                _ImDrawList->AddLine(ImVec2(临时玩家绘制信息.脖子屏幕ImVec2.x, 临时玩家绘制信息.脖子屏幕ImVec2.y), ImVec2(临时玩家绘制信息.屁股屏幕ImVec2.x, 临时玩家绘制信息.屁股屏幕ImVec2.y), 临时玩家绘制信息.IbIsAI ? IM_COL32(0, 255, 0, 255) : IM_COL32(255, 0, 0, 255), 1.0f);
                
                _ImDrawList->AddLine(ImVec2(临时玩家绘制信息.屁股屏幕ImVec2.x, 临时玩家绘制信息.屁股屏幕ImVec2.y), ImVec2(临时玩家绘制信息.左胯屏幕ImVec2.x, 临时玩家绘制信息.左胯屏幕ImVec2.y), 临时玩家绘制信息.IbIsAI ? IM_COL32(0, 255, 0, 255) : IM_COL32(255, 0, 0, 255), 1.0f);
                _ImDrawList->AddLine(ImVec2(临时玩家绘制信息.左胯屏幕ImVec2.x, 临时玩家绘制信息.左胯屏幕ImVec2.y), ImVec2(临时玩家绘制信息.左膝屏幕ImVec2.x, 临时玩家绘制信息.左膝屏幕ImVec2.y), 临时玩家绘制信息.IbIsAI ? IM_COL32(0, 255, 0, 255) : IM_COL32(255, 0, 0, 255), 1.0f);
                _ImDrawList->AddLine(ImVec2(临时玩家绘制信息.左膝屏幕ImVec2.x, 临时玩家绘制信息.左膝屏幕ImVec2.y), ImVec2(临时玩家绘制信息.左脚屏幕ImVec2.x, 临时玩家绘制信息.左脚屏幕ImVec2.y), 临时玩家绘制信息.IbIsAI ? IM_COL32(0, 255, 0, 255) : IM_COL32(255, 0, 0, 255), 1.0f);
                
                _ImDrawList->AddLine(ImVec2(临时玩家绘制信息.屁股屏幕ImVec2.x, 临时玩家绘制信息.屁股屏幕ImVec2.y), ImVec2(临时玩家绘制信息.右胯屏幕ImVec2.x, 临时玩家绘制信息.右胯屏幕ImVec2.y), 临时玩家绘制信息.IbIsAI ? IM_COL32(0, 255, 0, 255) : IM_COL32(255, 0, 0, 255), 1.0f);
                _ImDrawList->AddLine(ImVec2(临时玩家绘制信息.右胯屏幕ImVec2.x, 临时玩家绘制信息.右胯屏幕ImVec2.y), ImVec2(临时玩家绘制信息.右膝屏幕ImVec2.x, 临时玩家绘制信息.右膝屏幕ImVec2.y), 临时玩家绘制信息.IbIsAI ? IM_COL32(0, 255, 0, 255) : IM_COL32(255, 0, 0, 255), 1.0f);
                _ImDrawList->AddLine(ImVec2(临时玩家绘制信息.右膝屏幕ImVec2.x, 临时玩家绘制信息.右膝屏幕ImVec2.y), ImVec2(临时玩家绘制信息.右脚屏幕ImVec2.x, 临时玩家绘制信息.右脚屏幕ImVec2.y), 临时玩家绘制信息.IbIsAI ? IM_COL32(0, 255, 0, 255) : IM_COL32(255, 0, 0, 255), 1.0f);
            } else {
                _ImDrawList->AddCircleFilled(临时玩家绘制信息.屏幕边缘ImVec2, 36.0f, 临时玩家绘制信息.IbIsAI ? IM_COL32(0, 255, 0, 255) : IM_COL32(255, 0, 0, 180), 16);
                ImVec2 玩家名称字符长度 = ImGui::CalcTextSize([[NSString stringWithFormat:@"%.fm", 临时玩家绘制信息.距离] UTF8String]);
                [self 绘制文字:_ImDrawList 字符:[NSString stringWithFormat:@"%.fm", 临时玩家绘制信息.距离]  字体大小:22.0f 位置:ImVec2(临时玩家绘制信息.屏幕边缘ImVec2.x - 玩家名称字符长度.x / 2.0f, 临时玩家绘制信息.屏幕边缘ImVec2.y - 玩家名称字符长度.y / 2.0f) 颜色:IM_COL32_WHITE];
            };
            
            
    //        测试骨骼信息 临时骨骼信息;
    //        [Value getValue:&临时骨骼信息];
    //        for (int Index = 6; Index < 100; Index++) {
    //            [self 绘制文字:_ImDrawList 字符:[NSString stringWithFormat:@"%d", Index] 字体大小:8.0f 位置:ImVec2(临时骨骼信息.骨骼屏幕ImVec2[Index].x, 临时骨骼信息.骨骼屏幕ImVec2[Index].y) 颜色:IM_COL32_WHITE];
    //        };
    //        [self 绘制文字:_ImDrawList 字符:[NSString stringWithFormat:@"%d", 临时骨骼信息.骨骼点总数] 字体大小:12.0f 位置:ImVec2(临时骨骼信息.骨骼屏幕ImVec2[6].x, 临时骨骼信息.骨骼屏幕ImVec2[6].y) 颜色:IM_COL32(0, 255, 0, 255)];
        };
        
        for (NSValue* Value in 物资箱和死亡盒信息数组) {
            物资箱和死亡盒信息 临时物资箱和死亡盒信息;
            [Value getValue:&临时物资箱和死亡盒信息];
            NSString* 物资箱和死亡盒名称字符 = [self 获取物资箱和死亡盒名字:临时物资箱和死亡盒信息.IGameID 距离:临时物资箱和死亡盒信息.距离];
            ImVec2 物资箱和死亡盒名称字符长度 = ImGui::CalcTextSize([物资箱和死亡盒名称字符 UTF8String]);
            [self 绘制文字:_ImDrawList 字符:物资箱和死亡盒名称字符 字体大小:12.0f 位置:ImVec2(临时物资箱和死亡盒信息.屏幕ImVec2.x - 物资箱和死亡盒名称字符长度.x / 4.0f, 临时物资箱和死亡盒信息.屏幕ImVec2.y) 颜色:IM_COL32_WHITE];
//            if (物资箱和死亡盒列表信息数组 != nil) {
//                for (int Index = 0; Index < 物资箱和死亡盒列表信息数组.count; Index++) {
//                    int 物资ID = [物资箱和死亡盒列表信息数组[Index] unsignedIntValue];
//                    NSString* 物资ID名称 = [self 获取物资ID名称:物资ID];
//                    [self 绘制文字:_ImDrawList 字符:物资ID名称 字体大小:12.0f 位置:ImVec2(临时物资箱和死亡盒信息.显示屏幕ImVec2.x - 25.0f, 临时物资箱和死亡盒信息.显示屏幕ImVec2.y - Index * 20.0f - 40.0f) 颜色:IM_COL32_WHITE];
//                };
//            };
        };
        if (本地玩家信息数组.IbFreeCamera == 1 && 是否显示物资缓冲 == false) {
            是否显示物资 = !是否显示物资;
        };
        if (是否显示物资) {
            for (NSValue* Value in 物资信息数组) {
                物资信息 临时物资信息;
                [Value getValue:&临时物资信息];
                NSString* 物资名称字符 = [self 获取物资ID名称:临时物资信息.ITypeSpecificID];
                ImVec2 物资名称字符长度 = ImGui::CalcTextSize([物资名称字符 UTF8String]);
                [self 绘制文字:_ImDrawList 字符:物资名称字符 字体大小:12.0f 位置:ImVec2(临时物资信息.屏幕ImVec2.x - 物资名称字符长度.x / 4.0f, 临时物资信息.屏幕ImVec2.y) 颜色:IM_COL32_WHITE];
            };
            是否显示物资缓冲 = false;
        };
    };
    
    NSString* 玩家人数字符 = [NSString stringWithFormat:@"玩家 : %d", 玩家人数];
    ImVec2 玩家人数字符长度 = ImGui::CalcTextSize([玩家人数字符 UTF8String]);
    NSString* 人机人数字符 = [NSString stringWithFormat:@"人机 : %d", 人机人数];
    ImVec2 人机人数字符长度 = ImGui::CalcTextSize([人机人数字符 UTF8String]);
    [self 绘制文字:_ImDrawList 字符:玩家人数字符 字体大小:26.0f 位置:ImVec2(宽度 / 2.0f - 玩家人数字符长度.x / 2.0f - 60.0f, 75.0f) 颜色:IM_COL32(255, 0, 0, 255)];
    [self 绘制文字:_ImDrawList 字符:人机人数字符 字体大小:26.0f 位置:ImVec2(宽度 / 2.0f - 人机人数字符长度.x / 2.0f + 60.0f, 75.0f) 颜色:IM_COL32(0, 255, 0, 255)];
   
    ImGui::Render();
    id<MTLRenderCommandEncoder> _MTLRenderCommandEncoder = [_MTLCommandBuffer renderCommandEncoderWithDescriptor:_MTLRenderPassDescriptor];
    ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), _MTLCommandBuffer, _MTLRenderCommandEncoder);
    [_MTLRenderCommandEncoder endEncoding];
    [_MTLCommandBuffer presentDrawable:view.currentDrawable];
    [_MTLCommandBuffer commit];
};

- (void) 绘制文字:(ImDrawList*)ImDrawList 字符:(NSString*)字符 字体大小:(float)字体大小 位置:(ImVec2)位置 颜色:(ImU32)颜色 {
    ImFont* _ImFont = ImGui::GetFont();
    _ImFont->Scale = 字体大小 / _ImFont->FontSize;
    ImDrawList->AddText(_ImFont, 字体大小, ImVec2(位置.x + 1, 位置.y + 1), IM_COL32_BLACK, [字符 UTF8String]);
    ImDrawList->AddText(_ImFont, 字体大小, ImVec2(位置.x - 1, 位置.y - 1), IM_COL32_BLACK, [字符 UTF8String]);
    ImDrawList->AddText(_ImFont, 字体大小, ImVec2(位置.x + 1, 位置.y - 1), IM_COL32_BLACK, [字符 UTF8String]);
    ImDrawList->AddText(_ImFont, 字体大小, ImVec2(位置.x - 1, 位置.y + 1), IM_COL32_BLACK, [字符 UTF8String]);
    ImDrawList->AddText(_ImFont, 字体大小, ImVec2(位置.x, 位置.y), 颜色, [字符 UTF8String]);
};

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
};

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
};

- (void) 获取对象数组 {
    while (true) {
        NSMutableArray* 临时玩家数组 = [NSMutableArray array];
        NSMutableArray* 临时物资箱和死亡盒数组 = [NSMutableArray array];
        NSMutableArray* 临时物资数组 = [NSMutableArray array];
        
        if (无效地址判断(LWorld) || 无效地址判断(LGName)) continue;
        long LPersistentLevel = 读取<long>(LWorld + PersistentLevel);
        if (无效地址判断(LPersistentLevel)) continue;
        long 世界数组 = 读取<long>(LPersistentLevel + 0xA0);
        if (无效地址判断(世界数组)) continue;
        int 世界数量 = 读取<int>(LPersistentLevel + 0xA8);
        for (int Index = 0; Index < 世界数量; Index++) {
            long 对象 = 读取<long>(世界数组 + Index * 0x8);
            if (无效地址判断(对象)) continue;
            NSString* GName字符 = [self 获取GName字符:读取<int>(对象 + 0x18)];
            float FHighWalkSpeed = 读取<float>(对象 + HighWalkSpeed);
            int IbDead = 读取<int>(对象 + bDead);
            if ((FHighWalkSpeed == 479.5 || FHighWalkSpeed == 600.0f || [GName字符 containsString:@"BPPawn_Escape_BOSS_Freezing_C"]) && (IbDead == 0 || IbDead == 2)) {
                [临时玩家数组 addObject:@(对象)];
            } else if (![GName字符 containsString:@"BP_ScreenAppearanceActor_Escape_C"] && ![GName字符 containsString:@"BP_ScreenAppearanceActor_C"] &&
                       ![GName字符 containsString:@"BP_PlayerCameraManager_C"] && ![GName字符 containsString:@"BP_PlayerCameraManager_Escape_C"]) {
                int ITypeSpecificID = 读取<int>(对象 + DefineID + TypeSpecificID);
                if ([self 物资箱和死亡盒判断:GName字符]) { // [self 物资箱和死亡盒判断:GName字符]
                    [临时物资箱和死亡盒数组 addObject:@(对象)];
                } else if ([[NSString stringWithFormat:@"%d", ITypeSpecificID] length] >= 6 && 是否显示物资 && ITypeSpecificID != 1065353216) {
                    [临时物资数组 addObject:@(对象)];
                };
            };
        };
        
        玩家数组 = [临时玩家数组 copy];
        临时玩家数组 = nil;
        物资箱和死亡盒数组 = [临时物资箱和死亡盒数组 copy];
        临时物资箱和死亡盒数组 = nil;
        物资数组 = [临时物资数组 copy];
        临时物资数组 = nil;
        
        [NSThread sleepForTimeInterval:1.0f / 90.0f];
    };
};

- (void) 获取玩家信息 {
    while (true) {
        玩家信息 临时玩家信息;
        NSMutableArray* 临时玩家信息数组 = [NSMutableArray array];
        for (int Index = 0; Index < 玩家数组.count; Index++) {
            long 玩家 = [玩家数组[Index] unsignedLongValue];
            if (无效地址判断(玩家) || 玩家 == 本地玩家信息数组.LPawn) continue;
            int ITeamID = 读取<int>(玩家 + TeamID);
            if (ITeamID == 本地玩家信息数组.ITeamID) continue;
            int IbDead = 读取<int>(玩家 + bDead);
            if (IbDead == 1 || IbDead == 3) continue;
            Vector VRelativeLocation = [self 获取RelativeLocation:玩家];
            if (VRelativeLocation.X != -1.0f && VRelativeLocation.Y != -1.0f && VRelativeLocation.Z != -1.0f) {
                float 距离 = [self 获取对象屏幕距离:VRelativeLocation];
                if (距离 < 0.0f || 距离 > 300.0f) continue;
                临时玩家信息.IbIsAI = 读取<int>(玩家 + bIsAI);
                ImVec2 屏幕ImVec2 = [self 获取对象屏幕ImVec2:VRelativeLocation];
                if (屏幕ImVec2.x > 0.0f && 屏幕ImVec2.y > 0.0f && 屏幕ImVec2.x < 宽度 && 屏幕ImVec2.y < 高度) {
                    临时玩家信息.是否在屏幕内 = true;
                    临时玩家信息.ITeamID = ITeamID;
                    临时玩家信息.距离 = 距离;
                    临时玩家信息.VRelativeLocation = VRelativeLocation;
                    long LMesh = 读取<long>(玩家 + Mesh);
                    if (无效地址判断(LMesh)) continue;
                    临时玩家信息.LMesh = LMesh;
                    float FHealth = 读取<float>(玩家 + Health);
                    float FHealthMax = 读取<float>(玩家 + HealthMax);
                    临时玩家信息.百分比血量 = 100.0f * FHealth / FHealthMax;
                    临时玩家信息.LPlayerName = 读取<long>(玩家 + PlayerName);
                } else {
                    临时玩家信息.是否在屏幕内 = false;
                    临时玩家信息.屏幕边缘ImVec2 = [self 获取对象屏幕边缘ImVec2:屏幕ImVec2 屏幕左上角ImVec2:ImVec2(0.0f, 0.0f) 屏幕左下角ImVec2:ImVec2(0.0f, 高度) 屏幕右上角ImVec2:ImVec2(宽度, 0.0f) 屏幕左右下角ImVec2:ImVec2(宽度, 高度) 边缘预留值:30.0f];
                };
            };
            [临时玩家信息数组 addObject:[NSValue valueWithBytes:&临时玩家信息 objCType:@encode(玩家信息)]];
        };
        玩家信息数组 = [临时玩家信息数组 copy];
        临时玩家信息数组 = nil;
        
        [NSThread sleepForTimeInterval:1.0f / 90.0f];
    };
};

- (void) 获取玩家绘制信息 {
    while (true) {
        玩家绘制信息 临时玩家绘制信息;
        NSMutableArray* 临时玩家绘制信息数组 = [NSMutableArray array];
        for (NSValue* Value in 玩家信息数组) {
            玩家信息 临时玩家信息;
            [Value getValue:&临时玩家信息];
            临时玩家绘制信息.IbIsAI = 临时玩家信息.IbIsAI;
            临时玩家绘制信息.是否在屏幕内 = 临时玩家信息.是否在屏幕内;
            if (临时玩家信息.是否在屏幕内) {
                临时玩家绘制信息.ITeamID = 临时玩家信息.ITeamID;
                临时玩家绘制信息.距离 = 临时玩家信息.距离;
                临时玩家绘制信息.百分比血量 =  临时玩家信息.百分比血量;
                临时玩家绘制信息.LPlayerName = 临时玩家信息.LPlayerName;
                
                临时玩家绘制信息.屏幕ImVec4 = [self 获取对象屏幕ImVec4:临时玩家信息.VRelativeLocation];
                
                std::vector<int> 骨骼点数组 = [self 获取对象骨骼点数组:读取<int>(临时玩家信息.LMesh + StaticMesh + 0x8)];
            
                long LComponentToWorld = 临时玩家信息.LMesh + ComponentToWorld;
                long LStaticMesh = 读取<long>(临时玩家信息.LMesh + StaticMesh);
                if (无效地址判断(LStaticMesh)) continue;
                临时玩家绘制信息.头部屏幕ImVec2 = [self 获取骨骼屏幕ImVec2:LComponentToWorld LStaticMesh:LStaticMesh 骨骼点:6];
                临时玩家绘制信息.脖子屏幕ImVec2 = [self 获取骨骼屏幕ImVec2:LComponentToWorld LStaticMesh:LStaticMesh 骨骼点:5];
                
                临时玩家绘制信息.左肩屏幕ImVec2 = [self 获取骨骼屏幕ImVec2:LComponentToWorld LStaticMesh:LStaticMesh 骨骼点:骨骼点数组[0]];
                临时玩家绘制信息.左肘屏幕ImVec2 = [self 获取骨骼屏幕ImVec2:LComponentToWorld LStaticMesh:LStaticMesh 骨骼点:骨骼点数组[1]];
                临时玩家绘制信息.左手屏幕ImVec2 = [self 获取骨骼屏幕ImVec2:LComponentToWorld LStaticMesh:LStaticMesh 骨骼点:骨骼点数组[2]];
                
                临时玩家绘制信息.右肩屏幕ImVec2 = [self 获取骨骼屏幕ImVec2:LComponentToWorld LStaticMesh:LStaticMesh 骨骼点:骨骼点数组[3]];
                临时玩家绘制信息.右肘屏幕ImVec2 = [self 获取骨骼屏幕ImVec2:LComponentToWorld LStaticMesh:LStaticMesh 骨骼点:骨骼点数组[4]];
                临时玩家绘制信息.右手屏幕ImVec2 = [self 获取骨骼屏幕ImVec2:LComponentToWorld LStaticMesh:LStaticMesh 骨骼点:骨骼点数组[5]];
                
                临时玩家绘制信息.屁股屏幕ImVec2 = [self 获取骨骼屏幕ImVec2:LComponentToWorld LStaticMesh:LStaticMesh 骨骼点:1];
                
                临时玩家绘制信息.左胯屏幕ImVec2 = [self 获取骨骼屏幕ImVec2:LComponentToWorld LStaticMesh:LStaticMesh 骨骼点:骨骼点数组[6]];
                临时玩家绘制信息.左膝屏幕ImVec2 = [self 获取骨骼屏幕ImVec2:LComponentToWorld LStaticMesh:LStaticMesh 骨骼点:骨骼点数组[7]];
                临时玩家绘制信息.左脚屏幕ImVec2 = [self 获取骨骼屏幕ImVec2:LComponentToWorld LStaticMesh:LStaticMesh 骨骼点:骨骼点数组[8]];
                
                临时玩家绘制信息.右胯屏幕ImVec2 = [self 获取骨骼屏幕ImVec2:LComponentToWorld LStaticMesh:LStaticMesh 骨骼点:骨骼点数组[9]];
                临时玩家绘制信息.右膝屏幕ImVec2 = [self 获取骨骼屏幕ImVec2:LComponentToWorld LStaticMesh:LStaticMesh 骨骼点:骨骼点数组[10]];
                临时玩家绘制信息.右脚屏幕ImVec2 = [self 获取骨骼屏幕ImVec2:LComponentToWorld LStaticMesh:LStaticMesh 骨骼点:骨骼点数组[11]];
            } else {
                临时玩家绘制信息.屏幕边缘ImVec2 = 临时玩家信息.屏幕边缘ImVec2;
            };
            [临时玩家绘制信息数组 addObject:[NSValue valueWithBytes:&临时玩家绘制信息 objCType:@encode(玩家绘制信息)]];
        };
        
//        测试骨骼信息 临时骨骼信息;
//        NSMutableArray* 临时骨骼信息数组 = [NSMutableArray array];
//        for (NSValue* Value in 玩家信息数组) {
//            玩家信息 临时玩家信息;
//            [Value getValue:&临时玩家信息];
//            if (临时玩家信息.是否在屏幕内) {
//                临时骨骼信息.骨骼点总数 = 读取<int>(临时玩家信息.LMesh + StaticMesh + 0x8);
//                long LComponentToWorld = 临时玩家信息.LMesh + ComponentToWorld;
//                long LStaticMesh = 读取<long>(临时玩家信息.LMesh + StaticMesh);
//                for (int Index = 0; Index < 100; Index++) {
//                    临时骨骼信息.骨骼屏幕ImVec2[Index] = [self 获取骨骼屏幕ImVec2:LComponentToWorld LStaticMesh:LStaticMesh 骨骼点:Index];
//                };
//            };
//            [临时骨骼信息数组 addObject:[NSValue valueWithBytes:&临时骨骼信息 objCType:@encode(测试骨骼信息)]];
//        };
        
        玩家绘制信息数组 = [临时玩家绘制信息数组 copy];
        临时玩家绘制信息数组 = nil;
        
        [NSThread sleepForTimeInterval:1.0f / 90.0f];
    };
};

- (void) 获取物资箱和死亡盒信息 {
    while (true) {
        物资箱和死亡盒信息 临时物资箱和死亡盒信息;
        NSMutableArray* 临时物资箱和死亡盒信息数组 = [NSMutableArray array];
//        int 最大物资箱和死亡盒准星距离 = 20.0f;
//        long 显示物资箱和死亡盒 = -1;
//        NSMutableArray* 临时物资箱和死亡盒列表信息数组 = [NSMutableArray array];
        for (int Index = 0; Index < 物资箱和死亡盒数组.count; Index++) {
            long 物资箱和死亡盒 = [物资箱和死亡盒数组[Index] unsignedLongValue];
            if (无效地址判断(物资箱和死亡盒)) continue;
            Vector VRelativeLocation = [self 获取RelativeLocation:物资箱和死亡盒];
            if (VRelativeLocation.X != -1.0f && VRelativeLocation.Y != -1.0f && VRelativeLocation.Z != -1.0f) {
                float 距离 = [self 获取对象屏幕距离:VRelativeLocation];
                if (距离 < 0.0f || 距离 > 100.0f) continue;
                ImVec2 屏幕ImVec2 = [self 获取对象屏幕ImVec2:VRelativeLocation];
                if (屏幕ImVec2.x > 0.0f && 屏幕ImVec2.y > 0.0f && 屏幕ImVec2.x < 宽度 && 屏幕ImVec2.y < 高度) {
                    临时物资箱和死亡盒信息.屏幕ImVec2 = 屏幕ImVec2;
                    临时物资箱和死亡盒信息.IGameID = 读取<int>(物资箱和死亡盒 + 0x18);
                    临时物资箱和死亡盒信息.距离 = 距离;
//                    float 物资箱和死亡盒准星距离 = [self 获取对象准星距离:屏幕ImVec2];
                    
//                    if (物资箱和死亡盒准星距离 < 最大物资箱和死亡盒准星距离) {
//                        最大物资箱和死亡盒准星距离 = 物资箱和死亡盒准星距离;
//                        显示物资箱和死亡盒 = 物资箱和死亡盒;
//                        临时物资箱和死亡盒信息.显示屏幕ImVec2 = 屏幕ImVec2;
//                    } else {
//                        物资箱和死亡盒列表信息数组 = nil;
//                    };
                    
                    [临时物资箱和死亡盒信息数组 addObject:[NSValue valueWithBytes:&临时物资箱和死亡盒信息 objCType:@encode(物资箱和死亡盒信息)]];
                };
            };
        };
        
        if (是否显示物资) {
            物资信息 临时物资信息;
            NSMutableArray* 临时物资信息数组 = [NSMutableArray array];
            
            for (int Index = 0; Index < 物资数组.count; Index++) {
                long 物资 = [物资数组[Index] unsignedLongValue];
                if (无效地址判断(物资)) continue;
                Vector VRelativeLocation = [self 获取RelativeLocation:物资];
                if (VRelativeLocation.X != -1.0f && VRelativeLocation.Y != -1.0f && VRelativeLocation.Z != -1.0f) {
                    float 距离 = [self 获取对象屏幕距离:VRelativeLocation];
                    if (距离 < 0.0f || 距离 > 100.0f) continue;
                    ImVec2 屏幕ImVec2 = [self 获取对象屏幕ImVec2:VRelativeLocation];
                    if (屏幕ImVec2.x > 0.0f && 屏幕ImVec2.y > 0.0f && 屏幕ImVec2.x < 宽度 && 屏幕ImVec2.y < 高度) {
                        临时物资信息.屏幕ImVec2 = 屏幕ImVec2;
                        临时物资信息.ITypeSpecificID = 读取<int>(物资 + DefineID + TypeSpecificID);
                        临时物资信息.距离 = 距离;
                        [临时物资信息数组 addObject:[NSValue valueWithBytes:&临时物资信息 objCType:@encode(物资信息)]];
                    };
                };
            };
            
            物资信息数组 = [临时物资信息数组 copy];
            临时物资信息数组 = nil;
        };
        
            
//        if (!无效地址判断(显示物资箱和死亡盒)) {
//            long LPickUpDataList = 读取<long>(显示物资箱和死亡盒 + PickUpDataList);
//            if (无效地址判断(LPickUpDataList)) continue;
//            int 拾取列表总数 = 读取<int>(显示物资箱和死亡盒 + PickUpDataList + 0x8);
//            
//            for (int Index = 0; Index < 拾取列表总数; Index++) {
//                int 物资ID = 读取<int>(LPickUpDataList + 0x4 + Index * 0x38);
//                [临时物资箱和死亡盒列表信息数组 addObject:@(物资ID)];
//            };
//        };
        
        物资箱和死亡盒信息数组 = [临时物资箱和死亡盒信息数组 copy];
        临时物资箱和死亡盒信息数组 = nil;
       
        
//        物资箱和死亡盒列表信息数组 = [临时物资箱和死亡盒列表信息数组 copy];
//        临时物资箱和死亡盒列表信息数组 = nil;
        
        [NSThread sleepForTimeInterval:1.0f / 90.0f];
    };
};

- (NSString*) 获取GName字符:(int)IGameID {
    long 列地址 = 读取<long>(LGName + IGameID / 16384 * sizeof(long));
    long 行地址 = 读取<long>(列地址 + IGameID % 16384 * sizeof(long)) + 0xE;
    static char GName字符串[128];
    Vm_Read_OverWrite(行地址, GName字符串, sizeof(GName字符串));
    return [NSString stringWithUTF8String:GName字符串];
};

- (MinimalViewInfo) 获取MinimalViewInfo:(long)LPOV {
    Vector VLocation = {
        读取<float>(LPOV + Location),
        读取<float>(LPOV + Location + 0x4),
        读取<float>(LPOV + Location + 0x8),
    };
    Rotator RRotation = {
        读取<float>(LPOV + Rotation),
        读取<float>(LPOV + Rotation + 0x4),
        读取<float>(LPOV + Rotation + 0x8),
    };
    return {
        VLocation,
        RRotation,
        读取<float>(LPOV + FOV),
    };
};

- (Rotation矩阵) 获取Rotation矩阵:(Rotator)RRotation {
    三角函数 三Pitch = {
        sinf(RRotation.FPitch * M_PI / 180.0f),
        cosf(RRotation.FPitch * M_PI / 180.0f),
    };
    三角函数 三Yaw = {
        sinf(RRotation.FYaw * M_PI / 180.0f),
        cosf(RRotation.FYaw * M_PI / 180.0f),
    };
    三角函数 三Roll = {
        sinf(RRotation.FRoll * M_PI / 180.0f),
        cosf(RRotation.FRoll * M_PI / 180.0f),
    };
    return {
        三Pitch.余弦 * 三Yaw.余弦,
        三Pitch.余弦 * 三Yaw.正弦,
        三Pitch.正弦,
        
        三Pitch.正弦 * 三Yaw.余弦 * 三Roll.正弦 - 三Yaw.正弦 * 三Roll.余弦,
        三Pitch.正弦 * 三Yaw.正弦 * 三Roll.正弦 + 三Yaw.余弦 * 三Roll.余弦,
        -三Pitch.余弦 * 三Roll.正弦,
        
        -(三Pitch.正弦 * 三Yaw.余弦 * 三Roll.余弦 + 三Yaw.正弦 * 三Roll.正弦),
        三Yaw.余弦 * 三Roll.正弦 - 三Pitch.正弦 * 三Yaw.正弦 * 三Roll.余弦,
        三Pitch.余弦 * 三Roll.余弦,
    };
};

- (Vector) 获取RelativeLocation:(long)对象 {
    long LRootComponent = 读取<long>(对象 + RootComponent);
    if (无效地址判断(LRootComponent)) return {-1.0f, -1.0f, -1.0f};
    return {
        读取<float>(LRootComponent + RelativeLocation),
        读取<float>(LRootComponent + RelativeLocation + 0x4),
        读取<float>(LRootComponent + RelativeLocation + 0x8),
    };
};

- (Vector) 获取对象距离坐标:(Vector)VRelativeLocation 比例:(float) 比例 {
    return {
        (VRelativeLocation.X - 本地玩家信息数组.MMinimalViewInfo.VLocation.X) / 比例,
        (VRelativeLocation.Y - 本地玩家信息数组.MMinimalViewInfo.VLocation.Y) / 比例,
        (VRelativeLocation.Z - 本地玩家信息数组.MMinimalViewInfo.VLocation.Z) / 比例,
    };
};

- (float) 获取对象屏幕距离:(Vector)VRelativeLocation {
    Vector 对象距离坐标 = [self 获取对象距离坐标:VRelativeLocation 比例:100.0f];
    return ceilf(sqrtf(powf(对象距离坐标.X, 2.0f) + powf(对象距离坐标.Y, 2.0f) + powf(对象距离坐标.Z, 2.0f)));
};

- (ImVec2) 获取对象屏幕ImVec2:(Vector)VRelativeLocation {
    Vector 对象距离坐标 = [self 获取对象距离坐标:VRelativeLocation 比例:1.0f];
    Vector 世界转屏幕坐标 = {
        对象距离坐标.X * 本地玩家信息数组.RRotation矩阵._10 + 对象距离坐标.Y * 本地玩家信息数组.RRotation矩阵._11 + 对象距离坐标.Z * 本地玩家信息数组.RRotation矩阵._12,
        对象距离坐标.X * 本地玩家信息数组.RRotation矩阵._20 + 对象距离坐标.Y * 本地玩家信息数组.RRotation矩阵._21 + 对象距离坐标.Z * 本地玩家信息数组.RRotation矩阵._22,
        对象距离坐标.X * 本地玩家信息数组.RRotation矩阵._00 + 对象距离坐标.Y * 本地玩家信息数组.RRotation矩阵._01 + 对象距离坐标.Z * 本地玩家信息数组.RRotation矩阵._02,
    };
    if (世界转屏幕坐标.Z < 1.0f) 世界转屏幕坐标.Z = 1.0f;
    return {
        (宽度 / 2.0f) + 世界转屏幕坐标.X * ((宽度 / 2.0f) / tanf(本地玩家信息数组.MMinimalViewInfo.FFOV * M_PI / 360.0f)) / 世界转屏幕坐标.Z,
        (高度 / 2.0f) - 世界转屏幕坐标.Y * ((宽度 / 2.0f) / tanf(本地玩家信息数组.MMinimalViewInfo.FFOV * M_PI / 360.0f)) / 世界转屏幕坐标.Z,
    };
};

- (ImVec4) 获取对象屏幕ImVec4:(Vector)VRelativeLocation {
    Vector 顶部VRelativeLocation = {
        VRelativeLocation.X,
        VRelativeLocation.Y,
        VRelativeLocation.Z + 88.0f,
    };
    
    Vector 底部VRelativeLocation = {
        VRelativeLocation.X,
        VRelativeLocation.Y,
        VRelativeLocation.Z - 88.0f,
    };
    
    ImVec2 顶部对象屏幕ImVec2 = [self 获取对象屏幕ImVec2:顶部VRelativeLocation];
    ImVec2 底部对象屏幕ImVec2 = [self 获取对象屏幕ImVec2:底部VRelativeLocation];
    
    return {
        顶部对象屏幕ImVec2.x,
        顶部对象屏幕ImVec2.y,
        (底部对象屏幕ImVec2.y - 顶部对象屏幕ImVec2.y) / 2.0f,
        底部对象屏幕ImVec2.y - 顶部对象屏幕ImVec2.y,
    };
};

- (std::vector<int>) 获取对象骨骼点数组:(int) 骨骼点总数 {
    switch (骨骼点总数) {
        case 61:
            return {8, 9, 10, 29, 30, 31, 49, 50, 51, 53, 54, 55};
        case 63:
            return {9, 10, 11, 31, 32, 33, 51, 52, 53, 55, 56, 57};
        case 64:
            return {8, 9, 10, 30, 31, 32, 51, 52, 53, 57, 58, 59};
        case 65:
            return {12, 13, 14, 33, 34, 35, 53, 54, 55, 57, 58, 59};
        case 72:
            return {14, 15, 16, 36, 37, 38, 58, 59, 60, 62, 63, 64};
        case 95:
            return {29, 30, 31, 50, 51, 52, 63, 64, 65, 67, 68, 69};
        default:
            break;
    };
    return {12, 13, 14, 34, 35, 36, 56, 57, 58, 60, 61, 62};
};

- (Vector) 获取Translation:(long)LComponentToWorld或者LStaticMesh {
    return {
        读取<float>(LComponentToWorld或者LStaticMesh + Translation),
        读取<float>(LComponentToWorld或者LStaticMesh + Translation + 0x4),
        读取<float>(LComponentToWorld或者LStaticMesh + Translation + 0x8),
    };
};

- (Transform矩阵) 获取Transform矩阵:(Transform)TTransform {
    return {
        1.0f - (TTransform.QRotation.Y * TTransform.QRotation.Y * 2.0f + TTransform.QRotation.Z * TTransform.QRotation.Z * 2.0f) *TTransform.VScale3D.X,
        (TTransform.QRotation.X * TTransform.QRotation.Y * 2.0f + TTransform.QRotation.W * TTransform.QRotation.Z * 2.0f) * TTransform.VScale3D.X,
        (TTransform.QRotation.X * TTransform.QRotation.Z * 2.0f - TTransform.QRotation.W * TTransform.QRotation.Y * 2.0f) * TTransform.VScale3D.X,
        
        (TTransform.QRotation.X * TTransform.QRotation.Y * 2.0f - TTransform.QRotation.W * TTransform.QRotation.Z * 2.0f) * TTransform.VScale3D.Y,
        1.0f - (TTransform.QRotation.X * TTransform.QRotation.X * 2.0f + TTransform.QRotation.Z * TTransform.QRotation.Z * 2.0f) * TTransform.VScale3D.Y,
        (TTransform.QRotation.Y * TTransform.QRotation.Z * 2.0f + TTransform.QRotation.W * TTransform.QRotation.X * 2.0f) * TTransform.VScale3D.Y,
        
        (TTransform.QRotation.Y * TTransform.QRotation.Z * 2.0f - TTransform.QRotation.W * TTransform.QRotation.X * 2.0f) * TTransform.VScale3D.Z,
        1.0f - (TTransform.QRotation.X * TTransform.QRotation.X * 2.0f + TTransform.QRotation.Y * TTransform.QRotation.Y * 2.0f) * TTransform.VScale3D.Z,
        
        TTransform.VTranslation.X,
        TTransform.VTranslation.Y,
        TTransform.VTranslation.Z,
    };
};

- (ImVec2) 获取骨骼屏幕ImVec2:(long)LComponentToWorld LStaticMesh:(long)LStaticMesh 骨骼点:(int)骨骼点 {
    Transform TTransform = {
        读取<float>(LComponentToWorld),
        读取<float>(LComponentToWorld + 0x4),
        读取<float>(LComponentToWorld + 0x8),
        读取<float>(LComponentToWorld + 0xC),
        [self 获取Translation:LComponentToWorld],
        读取<float>(LComponentToWorld + Scale3D),
        读取<float>(LComponentToWorld + Scale3D + 0x4),
        读取<float>(LComponentToWorld + Scale3D + 0x8),
    };
    
    Transform矩阵 TTransform矩阵 = [self 获取Transform矩阵:TTransform];
    Vector VTranslation = [self 获取Translation:LStaticMesh + 骨骼点 * 0x30];
    
    Vector 世界转屏幕坐标 = {
        VTranslation.X * TTransform矩阵._00 + VTranslation.Y * TTransform矩阵._10 + VTranslation.Z * TTransform矩阵._20 + TTransform矩阵._30,
        VTranslation.X * TTransform矩阵._01 + VTranslation.Y * TTransform矩阵._11 + VTranslation.Z * TTransform矩阵._20 + TTransform矩阵._31,
        VTranslation.X * TTransform矩阵._02 + VTranslation.Y * TTransform矩阵._12 + VTranslation.Z * TTransform矩阵._21 + TTransform矩阵._32,
    };
    
    return [self 获取对象屏幕ImVec2:世界转屏幕坐标];
};

- (NSString*) 获取玩家名称:(long)LPlayerName {
    NSMutableString *名字字符 = [NSMutableString string];
       for (int Index = 0; Index < 14; Index++) {
           unichar 名字字符串 = 读取<unichar>(LPlayerName + Index * 2);
           if (名字字符串 == 0) break;
           [名字字符 appendFormat:@"%C", (unichar)名字字符串];
       }
       return [名字字符 copy];
};

- (bool) 物资箱和死亡盒判断:(NSString*)GName字符 {
    if ([GName字符 containsString:@"BP_TrainingBoxListWrapper_C"] ||
        [GName字符 containsString:@"TrainingMode_CoinChest_C"] ||
        [GName字符 containsString:@"CharacterDeadInventoryBox_C"] || [GName字符 containsString:@"BP_Escape_MonsterDeadInventoryBox_C"] || [GName字符 containsString:@"EscapePlayerTombBox_C"] || [GName字符 containsString:@"RollTombBox_C"] ||
        [GName字符 containsString:@"CG29_ActivityCommonTreasureBox_Ore_C"] ||
        [GName字符 containsString:@"EscapeBox_SupplyBox_Lv1_C"] || [GName字符 containsString:@"EscapeBox_SupplyBox_Lv2_C"] || [GName字符 containsString:@"EscapeBox_SupplyBox_Lv4_C"] ||
        [GName字符 containsString:@"EscapeBoxHight_SupplyBox_Lv1_C"] || [GName字符 containsString:@"EscapeBoxHight_SupplyBox_Lv2_C"] || [GName字符 containsString:@"EscapeBoxHight_SupplyBox_Lv3_C"] || [GName字符 containsString:@"EscapeBoxHight_SupplyBox_Lv4_C"] || [GName字符 containsString:@"EscapeBoxHight_SupplyBox_Lv5_C"] ||
        [GName字符 containsString:@"EscapeBox_Weapon_Lv1_C"] || [GName字符 containsString:@"EscapeBox_Weapon_Lv2_C"] || [GName字符 containsString:@"EscapeBox_Weapon_Lv4_C"] || [GName字符 containsString:@"EscapeBoxHight_Weapon_Lv4_C"] || [GName字符 containsString:@"EscapeBoxHight_Weapon_Lv1_C"] ||
        [GName字符 containsString:@"EscapeBox_Medical_Lv1_C"] || [GName字符 containsString:@"EscapeBox_Medical_Lv2_C"] || [GName字符 containsString:@"EscapeBoxHight_Medical_Lv2_C"] ||
        [GName字符 containsString:@"EscapeBox_FileCabinets_Lv1_C"] || [GName字符 containsString:@"EscapeBoxHight_FileCabinets_Lv1_C"] ||
        [GName字符 containsString:@"EscapeBox_Driefcase_Lv1_C"]) {
        return true;
    };
    return false;
};

- (NSString*) 获取物资箱和死亡盒名字:(int)IGameID  距离:(float)距离 {
    NSString* GName字符 = [self 获取GName字符:IGameID];
    
    if ([GName字符 containsString:@"BP_TrainingBoxListWrapper_C"]) {
        
       
        
    } else if ([GName字符 containsString:@"TrainingMode_CoinChest_C"]) {
        
        return [NSString stringWithFormat:@"[训练营] 乐园币箱(%.fm)", 距离];
        
    } else if ([GName字符 containsString:@"CharacterDeadInventoryBox_C"] || [GName字符 containsString:@"BP_Escape_MonsterDeadInventoryBox_C"] || [GName字符 containsString:@"EscapePlayerTombBox_C"] ||
               [GName字符 containsString:@"RollTombBox_C"]) {
        
            return [NSString stringWithFormat:@"[玩家] 死亡盒(%.fm)", 距离];
        
    } else if ([GName字符 containsString:@"CG29_ActivityCommonTreasureBox_Ore_C"]) {
        
        return [NSString stringWithFormat:@"[赛季] 活动物资箱(%.fm)", 距离];
        
    } else if ([GName字符 containsString:@"EscapeBox_SupplyBox_Lv1_C"] || [GName字符 containsString:@"EscapeBox_SupplyBox_Lv2_C"] || [GName字符 containsString:@"EscapeBox_SupplyBox_Lv4_C"] ||
               [GName字符 containsString:@"EscapeBoxHight_SupplyBox_Lv1_C"] || [GName字符 containsString:@"EscapeBoxHight_SupplyBox_Lv2_C"] || [GName字符 containsString:@"EscapeBoxHight_SupplyBox_Lv3_C"] || [GName字符 containsString:@"EscapeBoxHight_SupplyBox_Lv4_C"] || [GName字符 containsString:@"EscapeBoxHight_SupplyBox_Lv5_C"]) {
        
        return [NSString stringWithFormat:@"[地铁] 物资箱(%.fm)", 距离];
        
    }  else if ([GName字符 containsString:@"EscapeBox_Weapon_Lv1_C"] || [GName字符 containsString:@"EscapeBox_Weapon_Lv2_C"] || [GName字符 containsString:@"EscapeBox_Weapon_Lv4_C"] ||
                [GName字符 containsString:@"EscapeBoxHight_Weapon_Lv4_C"] || [GName字符 containsString:@"EscapeBoxHight_Weapon_Lv1_C"]) {
        
        return [NSString stringWithFormat:@"[地铁] 武器箱(%.fm)",距离];
        
    }  else if ([GName字符 containsString:@"EscapeBox_Medical_Lv1_C"] || [GName字符 containsString:@"EscapeBox_Medical_Lv2_C"] || [GName字符 containsString:@"EscapeBoxHight_Medical_Lv2_C"]) {
        
        return [NSString stringWithFormat:@"[地铁] 医疗箱(%.fm)", 距离];
        
    } else if ([GName字符 containsString:@"EscapeBox_FileCabinets_Lv1_C"] || [GName字符 containsString:@"EscapeBoxHight_FileCabinets_Lv1_C"]) {
        
        return [NSString stringWithFormat:@"[地铁] 文件柜(%.fm)", 距离];
        
    } else if ([GName字符 containsString:@"EscapeBox_Driefcase_Lv1_C"]) {
        
        return [NSString stringWithFormat:@"[地铁] 文件包(%.fm)", 距离];
        
    };
    
    return [NSString stringWithFormat:@"[训练营] 武器箱(%.fm)", 距离];
    
    // return GName字符;
};

- (float) 获取对象准星距离:(ImVec2)屏幕ImVec2 {
    ImVec2 对象准星坐标 = {
        abs(宽度 / 2.0f - 屏幕ImVec2.x),
        abs(高度 / 2.0f - 屏幕ImVec2.y),
    };
    
    return sqrtf(powf(对象准星坐标.x, 2.0f) + powf(对象准星坐标.y, 2.0f));
};

- (NSString*) 获取物资ID名称:(int) 物资ID {
    switch (物资ID) {
        case 503003:
            return @"军用防弹衣(3级)";
        case 503002:
            return @"警用防弹衣(2级)";
        case 503001:
            return @"警用防弹衣(1级)";
        case 502003:
            return @"特种部队头盔(3级)";
        case 502002:
            return @"军用头盔(2级)";
        case 502001:
            return @"摩托车头盔(1级)";
        case 501003:
            return @"背包(3级)";
        case 501002:
            return @"背包(2级)";
        case 501001:
            return @"背包(3级)";
            
        case 101013:
            return @"FAMAS突击步枪";
        case 101007:
            return @"QBZ突击步枪";
        case 101010:
            return @"G36C突击步枪";
        case 101006:
            return @"AUG突击步枪";
        case 101011:
            return @"AC-VAL突击步枪";
        case 101002:
            return @"M16A4突击步枪";
        case 101003:
            return @"SCAR-L突击步枪";
        case 101004:
            return @"M416突击步枪";
            
        case 101012:
            return @"蜜獾突击步枪";
        case 101009:
            return @"Mk47突击步枪";
        case 101005:
            return @"GROZA突击步枪";
        case 101008:
            return @"M762突击步枪";
        case 101001:
            return @"AKM突击步枪";
            
        case 103100:
            return @"MK12射手步枪";
        case 103014:
            return @"MK20-H射手步枪";
        case 103009:
            return @"SLR射手步枪";
        case 103007:
            return @"Mk14射手步枪";
        case 103010:
            return @"QBU射手步枪";
        case 103005:
            return @"VSS射手步枪";
        case 103006:
            return @"Mini14射手步枪";
        case 103004:
            return @"SKS射手步枪";
        case 103013:
            return @"M417射手步枪";
            
        case 103016:
            return @"SVD狙击枪";
        case 103015:
            return @"M200狙击枪";
        case 103012:
            return @"AMR狙击枪";
        case 103008:
            return @"Win94狙击枪";
        case 103001:
            return @"Kar98K狙击枪";
        case 103011:
            return @"莫辛纳甘狙击枪";
        case 103002:
            return @"M24狙击枪";
        case 103003:
            return @"AWM狙击枪";
            
        case 102008:
            return @"AKS-74U冲锋枪";
        case 102105:
            return @"P90冲锋枪";
        case 102004:
            return @"汤姆逊冲锋枪";
        case 102002:
            return @"UMP45冲锋枪";
        case 102005:
            return @"野牛冲锋枪";
        case 102003:
            return @"Vector冲锋枪";
        case 102007:
            return @"MP5K冲锋枪";
        case 102001:
            return @"UZI冲锋枪";
            
        case 106012:
            return @"双持柯尔特巨蟒";
        case 104005:
            return @"AA12-G霰弹枪";
        case 106011:
            return @"TMP-9手枪";
        case 106006:
            return @"短管霰弹枪";
        case 106001:
            return @"P92手枪";
        case 106003:
            return @"R1895手枪";
        case 106008:
            return @"蝎式手枪";
        case 106004:
            return @"P18C手枪";
        case 106005:
            return @"R45手枪";
        case 106002:
            return @"P1911手枪";
        case 106010:
            return @"沙漠之鹰手枪";
        case 104004:
            return @"DBS霰弹枪";
        case 104003:
            return @"S12K霰弹枪";
        case 104100:
            return @"SPAS-12霰弹枪";
        case 104002:
            return @"S1897霰弹枪";
            
        case 107909:
            return @"轻型迫击炮";
        case 105013:
            return @"MG-36轻机枪";
        case 107006:
            return @"战术弩";
        case 107008:
            return @"燃点复合弓";
        case 107010:
            return @"突击盾牌";
        case 105012:
            return @"PKM轻机枪";
        case 107001:
            return @"十字弩";
        case 107007:
            return @"爆炸猎弓";
        case 105002:
            return @"DP-28轻机枪";
        case 105010:
            return @"MG3轻机枪";
        case 105001:
            return @"M249轻机枪";
       
        case 602004:
            return @"破片手榴弹";
        case 108003:
            return @"镰刀";
        case 108002:
            return @"撬棍";
        case 108001:
            return @"大砍刀";
        case 108004:
            return @"平底锅";
            
        case 203030:
            return @"战术瞄准镜";
        case 203018:
            return @"侧面瞄准镜";
        case 203015:
            return @"6倍瞄准镜";
        case 203014:
            return @"3倍瞄准镜";
        case 203005:
            return @"8倍瞄准镜";
        case 203004:
            return @"4倍瞄准镜";
        case 203003:
            return @"2倍瞄准镜";
        case 203002:
            return @"全息瞄准镜";
        case 203001:
            return @"红点瞄准镜";
      
        case 204008:
            return @"快速弹匣(狙击枪)";
        case 204009:
            return @"快速扩容弹匣(狙击枪)";
        case 204007:
            return @"扩容弹匣(狙击枪)";
        case 204005:
            return @"快速弹匣(冲锋枪,手枪)";
        case 204006:
            return @"快速扩容弹匣(冲锋枪,手枪)";
        case 204004:
            return @"扩容弹匣(冲锋枪,手枪)";
        case 204012:
            return @"快速弹匣(步枪,机枪)";
        case 204013:
            return @"快速扩容弹匣(步枪,机枪)";
        case 204011:
            return @"扩容弹匣(步枪,机枪)";
            
        case 202002:
            return @"垂直握把";
        case 202006:
            return @"拇指握把";
        case 202004:
            return @"轻型握把";
        case 202001:
            return @"直角前握把";
        case 202007:
            return @"激光瞄准器";
        case 202005:
            return @"半截式握把";
            
        case 201007:
            return @"消音器(狙击枪)";
        case 201005:
            return @"消焰器(狙击枪)";
        case 201003:
            return @"枪口补偿器(狙击枪)";
        case 201006:
            return @"消音器(冲锋枪,手枪)";
        case 201004:
            return @"消焰器(冲锋枪)";
        case 201002:
            return @"枪口补偿器(冲锋枪)";
        case 201011:
            return @"快速弹匣(步枪,机枪)";
        case 201010:
            return @"消焰器(步枪)";
        case 201009:
            return @"枪口补偿器(步枪)";
            
        case 205011:
            return @"撞火枪托";
        case 204014:
            return @"子弹袋(狙击枪,霰弹枪)";
        case 205004:
            return @"箭袋(十字弩)";
        case 205001:
            return @"枪托(Micro UZI)";
        case 205003:
            return @"托腮板(狙击枪)";
        case 205002:
            return @"战术枪托(步枪,冲锋枪,机枪)";
        case 201012:
            return @"鸭嘴枪口(霰弹枪)";
        case 201001:
            return @"霰弹枪收束器";
        case 204017:
            return @"霰弹快速装填器";
            
            
        default:
            break;
    };
    return [NSString stringWithFormat:@"%d", 物资ID];
};

- (ImVec2) 获取屏幕边缘交点ImVec2:(ImVec2)屏幕ImVec2 边缘点一:(ImVec2)边缘点一 边缘点二:(ImVec2)边缘点二 {
    int 交点方向 = 0;
    ImVec2 交点;
    if (abs(宽度 / 2.0f - 屏幕ImVec2.x) > 0.0f) {
        交点.x = (屏幕ImVec2.y - 高度 / 2.0f) / (屏幕ImVec2.x - 宽度 / 2.0f);
        交点方向 |= 1;
    };
    if (abs(边缘点一.x - 边缘点二.x) > 0.0f) {
        交点.y = (边缘点二.y - 边缘点一.y) / (边缘点二.x - 边缘点一.x);
        交点方向 |= 2;
    };
    
    switch (交点方向) {
        case 0:
            return {0.0f, 0.0f};
        case 1:
            return {
                边缘点一.x,
                (宽度 / 2.0f - 边缘点一.x) * (-交点.x) + 宽度 / 2.0f,
            };
        case 2:
            return {
                宽度 / 2.0f,
                (边缘点一.x - 宽度 / 2.0f) * (-交点.y) + 边缘点一.y,
            };
        case 3: {
            if (abs(交点.x - 交点.y) < 0.0f) {
                return {0.0f, 0.0f};
            };
            return {
                (交点.x * 宽度 / 2.0f - 交点.y * 边缘点一.x - 高度 / 2.0f + 边缘点一.y) / (交点.x - 交点.y),
                交点.x * ((交点.x * 宽度 / 2.0f - 交点.y * 边缘点一.x - 高度 / 2.0f + 边缘点一.y) / (交点.x - 交点.y)) - 交点.x * 宽度 / 2.0f + 高度 / 2.0f,
            };
        };
    };
    return {0.0f, 0.0f};
};

- (ImVec2) 获取对象屏幕边缘ImVec2:(ImVec2)屏幕ImVec2 屏幕左上角ImVec2:(ImVec2)屏幕左上角ImVec2 屏幕左下角ImVec2:(ImVec2)屏幕左下角ImVec2 屏幕右上角ImVec2:(ImVec2)屏幕右上角ImVec2 屏幕左右下角ImVec2:(ImVec2)屏幕右下角ImVec2 边缘预留值:(float)边缘预留值 {
    if (屏幕ImVec2.x < 边缘预留值) {
        ImVec2 屏幕边缘交点ImVec2 = [self 获取屏幕边缘交点ImVec2:屏幕ImVec2 边缘点一:屏幕左上角ImVec2 边缘点二:屏幕左下角ImVec2];
        if (屏幕边缘交点ImVec2.y >= 边缘预留值 && 屏幕边缘交点ImVec2.y <= 屏幕右下角ImVec2.y) {
            return {边缘预留值, 屏幕边缘交点ImVec2.y - 边缘预留值};
        };
        if (屏幕ImVec2.y < 边缘预留值) {
            屏幕边缘交点ImVec2 = [self 获取屏幕边缘交点ImVec2:屏幕ImVec2 边缘点一:屏幕左上角ImVec2 边缘点二:屏幕右上角ImVec2];
            if (屏幕边缘交点ImVec2.x >= 边缘预留值 && 屏幕边缘交点ImVec2.x <= 屏幕右下角ImVec2.x) {
                return {屏幕边缘交点ImVec2.x - 边缘预留值, 边缘预留值};
            };
            return {边缘预留值, 边缘预留值};
        } else if (屏幕ImVec2.y > 屏幕右下角ImVec2.y) {
            屏幕边缘交点ImVec2 = [self 获取屏幕边缘交点ImVec2:屏幕ImVec2 边缘点一:屏幕左下角ImVec2 边缘点二:屏幕右下角ImVec2];
            if (屏幕边缘交点ImVec2.x >= 边缘预留值 && 屏幕边缘交点ImVec2.x <= 屏幕右下角ImVec2.x) {
                return {屏幕边缘交点ImVec2.x - 边缘预留值, 屏幕右下角ImVec2.y - 边缘预留值};
            };
            return {边缘预留值, 屏幕右下角ImVec2.y - 边缘预留值};
        } else {
            return {边缘预留值, 屏幕ImVec2.y - 边缘预留值};
        };
        
    } else if (屏幕ImVec2.x > 屏幕右下角ImVec2.x) {
        ImVec2 屏幕边缘交点ImVec2 = [self 获取屏幕边缘交点ImVec2:屏幕ImVec2 边缘点一:屏幕右上角ImVec2 边缘点二:屏幕右下角ImVec2];
        if (屏幕边缘交点ImVec2.y >= 边缘预留值 && 屏幕边缘交点ImVec2.y <= 屏幕右下角ImVec2.y) {
            return {屏幕右下角ImVec2.x - 边缘预留值, 屏幕边缘交点ImVec2.y - 边缘预留值};
        };
        
        if (屏幕边缘交点ImVec2.y < 边缘预留值) {
            屏幕边缘交点ImVec2 = [self 获取屏幕边缘交点ImVec2:屏幕ImVec2 边缘点一:屏幕左上角ImVec2 边缘点二:屏幕右上角ImVec2];
            if (屏幕边缘交点ImVec2.x >= 边缘预留值 && 屏幕边缘交点ImVec2.x <= 屏幕右下角ImVec2.x) {
                return {屏幕边缘交点ImVec2.x - 边缘预留值, 边缘预留值};
            };
            return {屏幕右下角ImVec2.x - 边缘预留值, 边缘预留值};
        } else if (屏幕ImVec2.y > 屏幕右下角ImVec2.y) {
            屏幕边缘交点ImVec2 = [self 获取屏幕边缘交点ImVec2:屏幕ImVec2 边缘点一:屏幕左下角ImVec2 边缘点二:屏幕右下角ImVec2];
            if (屏幕边缘交点ImVec2.x >= 边缘预留值 && 屏幕边缘交点ImVec2.x <= 屏幕右下角ImVec2.x) {
                return {屏幕边缘交点ImVec2.x - 边缘预留值, 屏幕右下角ImVec2.y - 边缘预留值};
            };
            return {屏幕右下角ImVec2.x - 边缘预留值, 屏幕右下角ImVec2.y - 边缘预留值};
        } else {
            return {屏幕右下角ImVec2.x - 边缘预留值, 屏幕ImVec2.y - 边缘预留值};
        };
        
    } else {
        
        if (屏幕ImVec2.y < 边缘预留值) {
            ImVec2 屏幕边缘交点ImVec2 = [self 获取屏幕边缘交点ImVec2:屏幕ImVec2 边缘点一:屏幕左上角ImVec2 边缘点二:屏幕右上角ImVec2];
            if (屏幕边缘交点ImVec2.x >= 边缘预留值 && 屏幕边缘交点ImVec2.x <= 屏幕右下角ImVec2.x) {
                return {屏幕边缘交点ImVec2.x - 边缘预留值, 边缘预留值};
            };
            return {屏幕ImVec2.x - 边缘预留值, 边缘预留值};
        } else if (屏幕ImVec2.y > 屏幕右下角ImVec2.y) {
            ImVec2 屏幕边缘交点ImVec2 = [self 获取屏幕边缘交点ImVec2:屏幕ImVec2 边缘点一:屏幕左上角ImVec2 边缘点二:屏幕右上角ImVec2];
            if (屏幕边缘交点ImVec2.x >= 边缘预留值 && 屏幕边缘交点ImVec2.x <= 屏幕右下角ImVec2.x) {
                return {屏幕边缘交点ImVec2.x - 边缘预留值, 屏幕右下角ImVec2.y - 边缘预留值};
            };
            return {屏幕ImVec2.x - 边缘预留值, 屏幕右下角ImVec2.y - 边缘预留值};
        } else {
            return {屏幕ImVec2.x - 边缘预留值, 屏幕ImVec2.y - 边缘预留值};
        };
        
    };
    return {边缘预留值, 边缘预留值};
};

@end
