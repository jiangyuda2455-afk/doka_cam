 # Doka Cam — AI 相机 App
 
 一个基于 Flutter 的跨平台 AI 相机应用，对标 Doka 相机的核心功能：
 **AI 实时构图辅助 / AI 胶片滤镜系统 / 极简拍摄体验**。
 
 ## 快速开始
 
 ### 前置要求
 
 - Flutter SDK >= 3.2.0（安装指南：[flutter.dev](https://flutter.dev/docs/get-started/install)）
 - Android Studio 或 Xcode（取决于目标平台）
 
 ### 启动步骤
 
 ```bash
 # 1. 进入项目目录
 cd doka_app
 
 # 2. 获取依赖
 flutter pub get
 
 # 3. 运行（连接真机或模拟器）
 flutter run
 ```
 
 > **注意**：iOS 需在 macOS 上构建，Android 可在 Windows/macOS/Linux 上构建。
 
 ## 功能模块
 
 | 模块 | 状态 | 说明 |
 |------|------|------|
 | 相机实时预览 | ✅ 完成 | Camera2 / AVFoundation 原生预览 |
 | 多摄切换 | ✅ 完成 | 前后镜头切换，焦段缩放 |
 | AI 构图辅助 | ⬜ 骨架 | 场景分类 + AR 叠加引导框，需集成 TFLite 模型 |
 | AI 滤镜系统 | ⬜ 骨架 | 3D LUT 渲染引擎，需提供 .cube 文件 |
 | 人像肤色保护 | ⬜ 骨架 | 人脸检测区域蒙版，需集成 FaceMesh |
 | 本地相册 | ✅ 完成 | SQLite 存储 + 网格展示 |
 | 基础编辑 | ✅ 完成 | 裁切、亮度/对比度调节 |
 | 胶片相框 | ⬜ 占位 | 需设计复古相框资源 |
 | 导出到系统相册 | ✅ 完成 | 本地存储 + 系统相册写入 |
 
 ## 项目结构
 
 ```
 lib/
 ├── main.dart                # 入口
 ├── app.dart                 # MaterialApp 配置
 ├── core/
 │   ├── camera/              # 相机控制器、帧处理器、镜头切换
 │   ├── ml/                  # ML 推理引擎（MediaPipe/TFLite 接口）
 │   ├── lut/                 # 3D LUT 加载与处理
 │   ├── composition/         # 构图规则引擎 + AR 叠加渲染
 │   ├── filter/              # 滤镜推荐 + 肤色保护
 │   └── storage/             # 本地存储 + 导出
 ├── features/
 │   ├── camera/              # 相机主界面
 │   ├── album/               # 相册
 │   ├── editor/              # 编辑器
 │   └── filter/              # 滤镜选择面板
 ├── models/                  # 数据模型
 └── shared/                  # 共享组件
 ```
 
 ## 下一步开发
 
 1. **LUT 文件**：将专业胶片 .cube 文件放入 `assets/luts/`
 2. **ML 模型**：将 TFLite 模型放入 `assets/models/`，然后在 `core/ml/` 中实现推理逻辑
 3. **相框 PNG**：将复古胶片边框放入 `assets/frames/`
 4. **iOS 配置**：在 macOS 上运行 `cd ios && pod install`
 
 ## 技术栈
 
 - **框架**：Flutter 3.x (Dart)
 - **相机**：camera: ^0.11.x
 - **存储**：sqflite + path_provider
 - **AI**：MediaPipe / TFLite（待集成）
 - **滤镜**：3D LUT (.cube)
 - **状态管理**：Provider
