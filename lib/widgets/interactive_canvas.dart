import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InteractiveCanvas extends StatefulWidget {
  final String? imagePath;
  final TransformationController controller;

  const InteractiveCanvas({
    super.key,
    required this.imagePath,
    required this.controller,
  });

  @override
  State<InteractiveCanvas> createState() => _InteractiveCanvasState();
}

class _InteractiveCanvasState extends State<InteractiveCanvas> {
  final GlobalKey _key = GlobalKey();
  final FocusNode _focusNode = FocusNode();

  // 滚轮缩放灵敏度
  static const double _kScrollScaleFactor = 0.001;
  // 最小/最大缩放比例
  static const double _kMinScale = 0.1;
  static const double _kMaxScale = 10.0;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagePath == null) {
      return Container(
        color: const Color(0xFF1E1E1E), // Figma dark grey
        width: double.infinity,
        height: double.infinity,
        child: const Center(
          child: Text(
            '没有图片',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.digit1, shift: true): () {
          // Shift+1: 适应屏幕 (Reset)
          widget.controller.value = Matrix4.identity();
        },
        const SingleActivator(LogicalKeyboardKey.digit0, shift: true): () {
          // Shift+0: 100% (暂时也重置，后续可优化为实际像素比例)
          widget.controller.value = Matrix4.identity();
        },
      },
      child: Focus(
        focusNode: _focusNode,
        child: Container(
          key: _key,
          color: const Color(0xFF1E1E1E),
          width: double.infinity,
          height: double.infinity,
          child: Listener(
            onPointerSignal: _handlePointerSignal,
            onPointerMove: _handlePointerMove,
            // 确保点击时获取焦点以启用快捷键
            onPointerDown: (_) => _focusNode.requestFocus(),
            child: ClipRect(
              child: GestureDetector(
                onDoubleTapDown: _handleDoubleTap,
                child: AnimatedBuilder(
                  animation: widget.controller,
                  builder: (context, child) {
                    return Transform(
                      transform: widget.controller.value,
                      alignment: Alignment.topLeft,
                      child: SizedBox.expand(
                        child: Image.file(
                          File(widget.imagePath!),
                          filterQuality: FilterQuality.medium, // 保证大图缩放质量
                          fit: BoxFit.contain, // 初始适应
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      // 1. 获取按键状态 (保留给未来扩展使用)
      // final keys = HardwareKeyboard.instance.logicalKeysPressed;
      // final isCtrlPressed = keys.contains(LogicalKeyboardKey.controlLeft) || ...
      
      // 2. 判断操作类型
      // 默认: 滚轮 = 缩放 (用户痛点需求)
      
      bool isZoom = true;
      
      if (isZoom) {
        _onZoom(event);
      }
    }
  }

  void _onZoom(PointerScrollEvent event) {
    // 计算缩放因子
    // event.scrollDelta.dy > 0 表示向下滚动（通常是缩小），< 0 向上滚动（放大）
    final double scaleChange =
        1.0 - (event.scrollDelta.dy * _kScrollScaleFactor);
    
    // 当前矩阵
    final Matrix4 matrix = widget.controller.value;
    
    // 限制缩放范围
    final double currentScale = matrix.getMaxScaleOnAxis();
    final double nextScale = currentScale * scaleChange;
    if (nextScale < _kMinScale || nextScale > _kMaxScale) {
      return;
    }

    // 缩放中心 (相对于 Widget 左上角的坐标)
    final Offset focalPoint = event.localPosition;

    // 矩阵变换算法：
    // 1. 将参考点(focalPoint)平移到原点
    // 2. 执行缩放
    // 3. 将参考点平移回去
    // Math: M' = T(p) * S(s) * T(-p) * M
    // 注意 Flutter Matrix4 乘法顺序是反直觉的 (pre-multiply vs post-multiply)
    // 正确的逻辑是：我们要基于当前的 focalPoint 进行缩放。
    // 新位置 = focalPoint + (旧位置 - focalPoint) * scale
    
    // 使用 Flutter 提供的便捷方法
    final Matrix4 translation = Matrix4.translationValues(
      focalPoint.dx,
      focalPoint.dy,
      0.0,
    );
    
    final Matrix4 scale = Matrix4.diagonal3Values(
      scaleChange,
      scaleChange,
      1.0,
    );
    
    final Matrix4 invTranslation = Matrix4.translationValues(
      -focalPoint.dx,
      -focalPoint.dy,
      0.0,
    );

    // 组合变换: T * S * T^-1 * Current
    // 这样变换是基于 Viewport 坐标系的
    widget.controller.value = translation * scale * invTranslation * matrix;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    // 检查是否按下了触发平移的键
    // final keys = HardwareKeyboard.instance.logicalKeysPressed;
    // final isSpacePressed = keys.contains(LogicalKeyboardKey.space);
    // final isCtrlPressed = keys.contains(LogicalKeyboardKey.controlLeft) || ...
    // final isMiddleMouse = event.buttons == kMiddleMouseButton;
    
    // 策略：始终允许平移，除非在进行其他操作。
    // 但为了响应用户的 "Ctrl+拖动" 习惯，我们确保 Ctrl 下也能拖动。
    
    final Matrix4 matrix = widget.controller.value;
    // 简单的平移：直接在第0,1列的第3行增加 delta (Matrix4 是列主序，translation 在 index 12, 13, 14)
    // 或者使用 translate 方法
    
    // 需要除以当前的缩放倍率吗？
    // 如果直接修改 Translation 部分，是在世界坐标系移动。
    // 鼠标移动的 delta 是屏幕坐标系。
    // 屏幕移动 10px，内容就应该移动 10px。所以不需要除以 scale。
    
    final Matrix4 translationDelta = Matrix4.translationValues(
      event.delta.dx,
      event.delta.dy,
      0.0,
    );
    
    // M' = T * M (在当前基础上平移)
    widget.controller.value = translationDelta * matrix;
  }
  
  void _handleDoubleTap(TapDownDetails details) {
    final Matrix4 currentMatrix = widget.controller.value;
    final double currentScale = currentMatrix.getMaxScaleOnAxis();

    if (currentScale > 1.1) {
      // 如果已经放大了，则复位
      widget.controller.value = Matrix4.identity();
    } else {
      // 如果是原始大小，则放大 2 倍到点击位置
      final Offset position = details.localPosition;
      
      final Matrix4 translation = Matrix4.translationValues(
        position.dx,
        position.dy,
        0.0,
      );

      final Matrix4 scale = Matrix4.diagonal3Values(
        2.0,
        2.0,
        1.0,
      );

      final Matrix4 invTranslation = Matrix4.translationValues(
        -position.dx,
        -position.dy,
        0.0,
      );

      widget.controller.value = translation * scale * invTranslation * currentMatrix;
    }
  }
}
