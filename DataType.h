#import "imgui.h"
#import "imgui_impl_metal.h"
#import <vector>

struct Vector {
    float X;
    float Y;
    float Z;
};

struct Rotator {
    float FPitch;
    float FYaw;
    float FRoll;
};

struct MinimalViewInfo {
    Vector VLocation;
    Rotator RRotation;
    float FFOV;
};

struct Rotation矩阵 {
    float _00, _01, _02;
    float _10, _11, _12;
    float _20, _21, _22;
};

struct 三角函数 {
    float 正弦;
    float 余弦;
};

struct ImGuiData {
    bool IsScreen;
    long UMesh;
    long UComponentToWorld;
    long UStaticMesh;
    float FHealth;
    long UPlayerName;
};

struct 本地玩家信息 {
    long LPawn;
    int ITeamID;
    int IbFreeCamera;
    MinimalViewInfo MMinimalViewInfo;
    Rotation矩阵 RRotation矩阵;
};

struct 玩家信息 {
    int ITeamID;
    float 距离;
    int IbIsAI;
    bool 是否在屏幕内;
    Vector VRelativeLocation;
    long LMesh;
    float 百分比血量;
    long LPlayerName;
    ImVec2 屏幕边缘ImVec2;
};

struct 玩家绘制信息 {
    int ITeamID;
    float 距离;
    int IbIsAI;
    bool 是否在屏幕内;
    float 百分比血量;
    long LPlayerName;
    ImVec4 屏幕ImVec4;
    ImVec2 屏幕边缘ImVec2;
    ImVec2 头部屏幕ImVec2;
    ImVec2 脖子屏幕ImVec2;
    ImVec2 左肩屏幕ImVec2;
    ImVec2 左肘屏幕ImVec2;
    ImVec2 左手屏幕ImVec2;
    ImVec2 右肩屏幕ImVec2;
    ImVec2 右肘屏幕ImVec2;
    ImVec2 右手屏幕ImVec2;
    ImVec2 屁股屏幕ImVec2;
    ImVec2 左胯屏幕ImVec2;
    ImVec2 左膝屏幕ImVec2;
    ImVec2 左脚屏幕ImVec2;
    ImVec2 右胯屏幕ImVec2;
    ImVec2 右膝屏幕ImVec2;
    ImVec2 右脚屏幕ImVec2;
};

//struct 测试骨骼信息 {
//    int 骨骼点总数;
//    std::array<ImVec2, 100> 骨骼屏幕ImVec2;
//};

struct 物资箱和死亡盒信息 {
    float 距离;
    ImVec2 屏幕ImVec2;
    int IGameID;
};

struct 物资信息 {
    float 距离;
    ImVec2 屏幕ImVec2;
    int ITypeSpecificID;
};

struct Quat {
    float X;
    float Y;
    float Z;
    float W;
};

struct Transform {
    Quat QRotation;
    Vector VTranslation;
    Vector VScale3D;
};

struct Transform矩阵 {
    float _00, _01, _02;
    float _10, _11, _12;
    float _20, _21;
    float _30, _31, _32;
};
