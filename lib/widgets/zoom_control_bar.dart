import 'package:flutter/material.dart';

class ZoomControlBar extends StatefulWidget {
  final TransformationController controller;
  final VoidCallback? onReset;

  const ZoomControlBar({
    super.key,
    required this.controller,
    this.onReset,
  });

  @override
  State<ZoomControlBar> createState() => _ZoomControlBarState();
}

class _ZoomControlBarState extends State<ZoomControlBar> {
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _onControllerChanged(); // 初始化值
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    final scale = widget.controller.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() > 0.01) {
      setState(() {
        _currentScale = scale;
      });
    }
  }

  void _onSliderChanged(double value) {
    // 保持中心点缩放会比较复杂，这里简化为重置 scale
    // 或者我们只改变 scale 因子，但保留 translation
    final matrix = widget.controller.value.clone();
    
    // 简单的缩放处理：
    // 获取当前平移
    final translation = matrix.getTranslation();
    
    // 构建新矩阵：保持平移，应用新缩放
    // 注意：这样改变缩放是基于原点的，可能会导致视图跳跃。
    // 更好的做法是：
    // 如果是用户拖动 slider，我们通常希望“原地”缩放或者“中心”缩放。
    // 鉴于这是一个 slider，我们简单地以 Viewport 中心进行缩放比较合理，但实现复杂。
    // 简单实现：只修改 scale 可能会导致位置偏移。
    // 暂时实现：直接修改 Scale，用户可能需要手动拖拽调整位置。
    
    // 优化：尝试保持当前的 translation
    final newMatrix = Matrix4.identity()
      ..translate(translation.x, translation.y)
      ..scale(value);
      
    widget.controller.value = newMatrix;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: const Color(0xFF2C2C2C),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // 缩放百分比显示
          SizedBox(
            width: 60,
            child: Text(
              '${(_currentScale * 100).round()}%',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          // 缩小按钮
          IconButton(
            icon: const Icon(Icons.remove, size: 16, color: Colors.white70),
            onPressed: () {
              final newScale = (_currentScale - 0.1).clamp(0.1, 10.0);
              _onSliderChanged(newScale);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          // 滑动条
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.blueAccent,
                inactiveTrackColor: Colors.grey[700],
                thumbColor: Colors.white,
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                value: _currentScale.clamp(0.1, 10.0),
                min: 0.1,
                max: 10.0, 
                onChanged: _onSliderChanged,
              ),
            ),
          ),
          // 放大按钮
          IconButton(
            icon: const Icon(Icons.add, size: 16, color: Colors.white70),
            onPressed: () {
              final newScale = (_currentScale + 0.1).clamp(0.1, 10.0);
              _onSliderChanged(newScale);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          // 复位按钮
          IconButton(
            icon: const Icon(Icons.restart_alt, size: 16, color: Colors.white70),
            onPressed: widget.onReset ?? () {
              widget.controller.value = Matrix4.identity();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: '重置视图 (Shift+1)',
          ),
        ],
      ),
    );
  }
}
