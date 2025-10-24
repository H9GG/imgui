#import <sys/sysctl.h>
#import <mach-o/dyld_images.h>
#import <libgen.h>

static mach_port_t 任务端口;

extern "C" {
    kern_return_t mach_vm_read(vm_map_t target_task, mach_vm_address_t address, mach_vm_size_t size, vm_offset_t *data, mach_msg_type_number_t *dataCnt);
    kern_return_t mach_vm_read_overwrite(vm_map_t target_task, mach_vm_address_t address, mach_vm_size_t size, mach_vm_address_t data, mach_vm_size_t *outsize);
    
    struct dyld_image_info64 {
        mach_vm_address_t imageLoadAddress;
        mach_vm_address_t imageFilePath;
        mach_vm_size_t    imageFileModDate;
    };
    
    struct dyld_all_image_infos64 {
        uint32_t            version;
        uint32_t            infoArrayCount;
        mach_vm_address_t   infoArray;
        dyld_image_notifier notification;
        bool                processDetachedFromSharedRegion;
        bool                libSystemInitialized;
        mach_vm_address_t   dyldImageLoadAddress;
        mach_vm_address_t   jitInfo;
        mach_vm_address_t   dyldVersion;
        mach_vm_address_t   errorMessage;
        uint64_t            terminationFlags;
        mach_vm_address_t   coreSymbolicationShmPage;
        uint64_t            systemOrderFlag;
        uint64_t            uuidArrayCount;
        mach_vm_address_t   uuidArray;
        mach_vm_address_t   dyldAllImageInfosAddress;
        uint64_t            initialImageCount;
        uint64_t            errorKind;
        mach_vm_address_t   errorClientOfDylibPath;
        mach_vm_address_t   errorTargetDylibPath;
        mach_vm_address_t   errorSymbol;
        uint64_t            sharedCacheSlide;
    };
};

pid_t 获取进程ID(NSString* 进程字符) {
    size_t 进程列表长度 = 0;
    static const int 系统参数列表[] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    int 返回结果 = sysctl((int*)系统参数列表, (sizeof(系统参数列表) / sizeof(*系统参数列表)) - 1, nullptr, &进程列表长度, nullptr, 0);
    if (返回结果 == 0 && 进程列表长度 > 0) {
        static kinfo_proc* 进程列表 = (struct kinfo_proc*)malloc(进程列表长度);
        if (进程列表 == nullptr) return -1;
        返回结果 = sysctl((int*)系统参数列表, (sizeof(系统参数列表) / sizeof(*系统参数列表)) - 1, 进程列表, &进程列表长度, nullptr, 0);
        if (返回结果 == 0) {
            int 进程总数 = (int)进程列表长度 / sizeof(struct kinfo_proc);
            pid_t 进程ID = -1;
            for (int Index = 0; Index < 进程总数; Index++) {
                NSString* 当前进程字符 = [NSString stringWithUTF8String:进程列表[Index].kp_proc.p_comm];
                if ([当前进程字符 containsString:进程字符]) {
                    进程ID = 进程列表[Index].kp_proc.p_pid;
                    break;
                };
            };
            if (进程ID > 0) {
                free(进程列表);
                return 进程ID;
            };
        };
        if (进程列表 != nullptr) free(进程列表);
    };
    return -1;
};

long 获取模块地址(pid_t 进程ID, NSString* 模块字符) {
    kern_return_t 返回结果 = task_for_pid(mach_task_self(), 进程ID, &任务端口);
    if (返回结果 != KERN_SUCCESS) return -1;
    
    task_dyld_info_data_t Task_Dyld_Info_Data_T;
    mach_msg_type_number_t Mach_Msg_Type_Number_T = TASK_DYLD_INFO_COUNT;
    
    返回结果 = task_info(任务端口, TASK_DYLD_INFO, (task_info_t)&Task_Dyld_Info_Data_T, &Mach_Msg_Type_Number_T);
    if (返回结果 != KERN_SUCCESS) return -1;
    struct dyld_all_image_infos64 Dyld_All_Image_Infos64;
    mach_vm_size_t Mach_Vm_Size_T = sizeof(Dyld_All_Image_Infos64);
    
    返回结果 = mach_vm_read_overwrite(任务端口, Task_Dyld_Info_Data_T.all_image_info_addr, Mach_Vm_Size_T, (mach_vm_address_t)&Dyld_All_Image_Infos64, &Mach_Vm_Size_T);
    if (返回结果 != KERN_SUCCESS) return -1;
    
    mach_vm_address_t InfoArray = Dyld_All_Image_Infos64.infoArray;
    mach_msg_type_number_t InfoArrayCount = (uint32_t)Dyld_All_Image_Infos64.infoArrayCount * sizeof(struct dyld_image_info64);
    
    返回结果 = mach_vm_read(任务端口, InfoArray, InfoArrayCount, (vm_offset_t*)&InfoArray, &InfoArrayCount);
    if (返回结果 != KERN_SUCCESS) return -1;
    
    for (int Index = 0; Index < (uint32_t)Dyld_All_Image_Infos64.infoArrayCount; Index++) {
        struct dyld_image_info64* Array = (struct dyld_image_info64*) InfoArray;
        mach_vm_address_t ImageLoadAddress = Array[Index].imageLoadAddress;
        mach_vm_address_t ImageFilePath = Array[Index].imageFilePath;
        
        char _PATH_MAX[PATH_MAX] = {0};
        mach_vm_size_t Count;
        if (mach_vm_read_overwrite(任务端口, ImageFilePath, MAXPATHLEN, (mach_vm_address_t)_PATH_MAX, &Count) == KERN_SUCCESS) {
            if ([模块字符 isEqual:[NSString stringWithUTF8String:basename((char*)_PATH_MAX)]]) {
                return ImageLoadAddress;
                break;
            };
        };
    };
    return -1;
};

bool 无效地址判断(long 内存地址) {
    if (内存地址 < 0x100000000 || 内存地址 > 0x300000000) return true;
        return false;
};

bool Vm_Read_OverWrite(long 内存地址, void* 内存值, int 读取长度) {
    vm_size_t 内存长度 = 0;
    kern_return_t 返回结果 = vm_read_overwrite(任务端口, (vm_address_t)内存地址, 读取长度, (vm_address_t)内存值, &内存长度);
    if (返回结果 == KERN_SUCCESS && 读取长度 == 内存长度) return true;
    return false;
};

bool Vm_Write(long 内存地址, void* 内存值, int 写入长度) {
    kern_return_t 返回结果 = vm_write(任务端口, (vm_address_t)内存地址, (vm_address_t)内存值, (mach_msg_type_number_t)写入长度);
    if (返回结果 == KERN_SUCCESS) return true;
    return false;
};

template<typename 数据类型> 数据类型 读取(long 内存地址) {
    数据类型 内存值;
    Vm_Read_OverWrite(内存地址, reinterpret_cast<void*>(&内存值), sizeof(数据类型));
    return 内存值;
};

template<typename 数据类型> void 写入(long 内存地址, 数据类型 内存值) {
    Vm_Write(内存地址, &内存值, sizeof(数据类型));
};
