import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:desktop_drop/desktop_drop.dart';
import '../controllers/sync_controller.dart';
import '../widgets/interactive_canvas.dart';
import '../widgets/zoom_control_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SyncController _syncController = SyncController();
  
  bool _isDraggingLeft = false;
  bool _isDraggingRight = false;

  @override
  void dispose() {
    _syncController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isLeft) async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: <String>['jpg', 'png', 'jpeg', 'webp', 'bmp', 'gif'],
    );
    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    
    if (file != null) {
      if (isLeft) {
        _syncController.setLeftImage(file.path);
      } else {
        _syncController.setRightImage(file.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Column(
        children: [
          // Toolbar
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: const Color(0xFF2C2C2C),
            child: Row(
              children: [
                const Text(
                  'DualView',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 32),
                _buildButton(
                  icon: Icons.image,
                  label: '打开左图',
                  onTap: () => _pickImage(true),
                ),
                const SizedBox(width: 16),
                _buildButton(
                  icon: Icons.image_outlined,
                  label: '打开右图',
                  onTap: () => _pickImage(false),
                ),
                const Spacer(),
                // Sync Toggle
                AnimatedBuilder(
                  animation: _syncController,
                  builder: (context, _) {
                    final isSync = _syncController.isSyncEnabled;
                    return TextButton.icon(
                      onPressed: _syncController.toggleSync,
                      style: TextButton.styleFrom(
                        backgroundColor: isSync ? Colors.blueAccent : Colors.transparent,
                        foregroundColor: isSync ? Colors.white : Colors.grey,
                      ),
                      icon: Icon(isSync ? Icons.link : Icons.link_off),
                      label: Text(isSync ? '同步开启' : '同步关闭'),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Row(
              children: [
                // Left View
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: DropTarget(
                          onDragDone: (detail) {
                            if (detail.files.isNotEmpty) {
                              _syncController.setLeftImage(detail.files.first.path);
                            }
                          },
                          onDragEntered: (detail) {
                            setState(() {
                              _isDraggingLeft = true;
                            });
                          },
                          onDragExited: (detail) {
                            setState(() {
                              _isDraggingLeft = false;
                            });
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AnimatedBuilder(
                                animation: _syncController,
                                builder: (context, _) {
                                  return InteractiveCanvas(
                                    imagePath: _syncController.leftImagePath,
                                    controller: _syncController.leftController,
                                  );
                                },
                              ),
                              if (_isDraggingLeft)
                                Container(
                                  color: Colors.blueAccent.withValues(alpha: 0.2),
                                  child: const Center(
                                    child: Icon(Icons.add_photo_alternate, size: 64, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Left Zoom Bar
                      ZoomControlBar(
                        controller: _syncController.leftController,
                      ),
                    ],
                  ),
                ),
                
                // Divider
                Container(
                  width: 1,
                  color: const Color(0xFF444444),
                ),
                
                // Right View
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: DropTarget(
                          onDragDone: (detail) {
                            if (detail.files.isNotEmpty) {
                              _syncController.setRightImage(detail.files.first.path);
                            }
                          },
                          onDragEntered: (detail) {
                            setState(() {
                              _isDraggingRight = true;
                            });
                          },
                          onDragExited: (detail) {
                            setState(() {
                              _isDraggingRight = false;
                            });
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AnimatedBuilder(
                                animation: _syncController,
                                builder: (context, _) {
                                  return InteractiveCanvas(
                                    imagePath: _syncController.rightImagePath,
                                    controller: _syncController.rightController,
                                  );
                                },
                              ),
                              if (_isDraggingRight)
                                Container(
                                  color: Colors.blueAccent.withValues(alpha: 0.2),
                                  child: const Center(
                                    child: Icon(Icons.add_photo_alternate, size: 64, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Right Zoom Bar
                      ZoomControlBar(
                        controller: _syncController.rightController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: Colors.white70),
      label: Text(label, style: const TextStyle(color: Colors.white70)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
