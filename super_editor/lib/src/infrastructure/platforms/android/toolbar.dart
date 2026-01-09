import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:super_editor/src/infrastructure/flutter/android_toolbar.dart';

class AndroidTextEditingFloatingToolbar extends StatefulWidget {
  const AndroidTextEditingFloatingToolbar({
    Key? key,
    this.focalPoint,
    this.floatingToolbarKey,
    this.cutTitle,
    this.onCutPressed,
    this.copyTitle,
    this.onCopyPressed,
    this.pasteTitle,
    this.onPastePressed,
    this.selectAllTitle,
    this.onSelectAllPressed,
  }) : super(key: key);

  final Key? floatingToolbarKey;
  final LeaderLink? focalPoint;

  final String? cutTitle;
  final VoidCallback? onCutPressed;
  final String? copyTitle;
  final VoidCallback? onCopyPressed;
  final String? pasteTitle;
  final VoidCallback? onPastePressed;
  final String? selectAllTitle;
  final VoidCallback? onSelectAllPressed;

  @override
  State<AndroidTextEditingFloatingToolbar> createState() => _AndroidTextEditingFloatingToolbarState();
}

class _AndroidTextEditingFloatingToolbarState extends State<AndroidTextEditingFloatingToolbar> {
  /// Whether the toolbar is above or below the focal point.
  ///
  /// This is used to determine the position of the back button in the overflow menu.
  bool _isAbove = true;

  @override
  void initState() {
    super.initState();
    widget.focalPoint?.addListener(_onFocalPointChange);
  }

  @override
  void didUpdateWidget(AndroidTextEditingFloatingToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focalPoint != widget.focalPoint) {
      oldWidget.focalPoint?.removeListener(_onFocalPointChange);
      widget.focalPoint?.addListener(_onFocalPointChange);
    }
  }

  @override
  void dispose() {
    widget.focalPoint?.removeListener(_onFocalPointChange);
    super.dispose();
  }

  void _onFocalPointChange() {
    final leader = widget.focalPoint?.leader;
    if (leader == null) {
      return;
    }

    final box = context.findRenderObject() as RenderBox?;
    if (box == null) {
      return;
    }

    final leaderOffset = leader.offset;
    final followerOffset = box.localToGlobal(Offset.zero);
    final isAbove = followerOffset < leaderOffset;

    if (isAbove != _isAbove) {
      setState(() {
        _isAbove = isAbove;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final buttons = <_ButtonViewModel>[
      if (widget.onCutPressed != null)
        _ButtonViewModel(
          onPressed: widget.onCutPressed!,
          title: widget.cutTitle ?? 'Cut',
        ),
      if (widget.onCopyPressed != null)
        _ButtonViewModel(
          onPressed: widget.onCopyPressed!,
          title: widget.copyTitle ?? 'Copy',
        ),
      if (widget.onPastePressed != null)
        _ButtonViewModel(
          onPressed: widget.onPastePressed!,
          title: widget.pasteTitle ?? 'Paste',
        ),
      if (widget.onSelectAllPressed != null)
        _ButtonViewModel(
          onPressed: widget.onSelectAllPressed!,
          title: widget.selectAllTitle ?? 'Select All',
        ),
    ];

    return KeyedSubtree(
      key: widget.floatingToolbarKey,
      child: AndroidPopoverToolbar(
        isAbove: _isAbove,
        toolbarBuilder: _defaultToolbarBuilder,
        children: [
          for (int i = 0; i < buttons.length; i++)
            TextSelectionToolbarTextButton(
              padding: TextSelectionToolbarTextButton.getPadding(i, buttons.length),
              onPressed: buttons[i].onPressed,
              alignment: AlignmentDirectional.centerStart,
              child: Text(buttons[i].title),
            ),
        ],
      ),
    );
  }
}

Widget _defaultToolbarBuilder(BuildContext context, Widget child) {
  return AndroidPopoverToolbarContainer(child: child);
}

class _ButtonViewModel {
  _ButtonViewModel({
    required this.title,
    required this.onPressed,
  });

  final String title;
  final VoidCallback onPressed;
}
