import 'package:flutter/material.dart';

class SyncController extends ChangeNotifier {
  final TransformationController leftController = TransformationController();
  final TransformationController rightController = TransformationController();

  String? leftImagePath;
  String? rightImagePath;

  bool isSyncEnabled = false;

  SyncController() {
    leftController.addListener(_onLeftChanged);
    rightController.addListener(_onRightChanged);
  }

  bool _isSyncing = false;

  void _onLeftChanged() {
    if (!isSyncEnabled || _isSyncing) return;
    _sync(leftController, rightController);
  }

  void _onRightChanged() {
    if (!isSyncEnabled || _isSyncing) return;
    _sync(rightController, leftController);
  }

  void _sync(TransformationController source, TransformationController target) {
    _isSyncing = true;
    target.value = source.value;
    _isSyncing = false;
  }

  void setLeftImage(String path) {
    leftImagePath = path;
    notifyListeners();
  }

  void setRightImage(String path) {
    rightImagePath = path;
    notifyListeners();
  }

  void toggleSync() {
    isSyncEnabled = !isSyncEnabled;
    if (isSyncEnabled) {
      // 开启同步时，以左侧为准对齐右侧
      // Sync right to left when enabled
      rightController.value = leftController.value;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    leftController.removeListener(_onLeftChanged);
    rightController.removeListener(_onRightChanged);
    leftController.dispose();
    rightController.dispose();
    super.dispose();
  }
}
