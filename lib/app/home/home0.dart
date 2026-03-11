// Copyright (C) 2026 5V Network LLC <5vnetwork@proton.me>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

part of 'home.dart';

// class ProHomePage extends StatefulWidget {
//   const ProHomePage({super.key});

//   @override
//   State<ProHomePage> createState() => _ProHomePageState();
// }

// class _ProHomePageState extends State<ProHomePage> {
//   late final SharedPreferences _prefs;
//   late final DashboardController _controller;
//   late final HomeDashboardEditNotifier _editNotifier;

//   @override
//   void initState() {
//     super.initState();
//     _prefs = context.read<SharedPreferences>();
//     _editNotifier = context.read<HomeDashboardEditNotifier>();
//     _controller = DashboardController(
//       initialLayout: const [],
//       onLayoutChanged: (_, __) => _saveLayout(),
//     );
//     if (_prefs.homeDashboardLayout != null) {
//       _controller.importLayout(_prefs.homeDashboardLayout!);
//     } else {
//       _controller.addItems(defaultHomeDashboardLayout);
//     }
//     _controller.setEditMode(_editNotifier.isEditing);
//     _editNotifier.addListener(_onEditModeChanged);
//   }

//   void _onEditModeChanged() {
//     if (!mounted) return;
//     _controller.setEditMode(_editNotifier.isEditing);
//   }

//   @override
//   void dispose() {
//     _editNotifier.removeListener(_onEditModeChanged);
//     _controller.dispose();
//     super.dispose();
//   }

//   void _saveLayout() {
//     final items = _controller.exportLayout();
//     inspect(items);
//     _prefs.setHomeDashboardLayout(items);
//   }

//   void _cancelEdit() {
//     for (final item in _controller.exportLayout()) {
//       _controller.removeItem(item['id']);
//     }
//     if (_prefs.homeDashboardLayout != null) {
//       _controller.importLayout(_prefs.homeDashboardLayout!);
//     } else {
//       _controller.addItems(defaultHomeDashboardLayout);
//     }
//   }

//   void _restoreToDefault() {
//     _prefs.clearHomeDashboardLayout();
//     for (final item in _controller.exportLayout()) {
//       _controller.removeItem(item['id']);
//     }
//     _controller.addItems(defaultHomeDashboardLayout);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEditing = context.watch<HomeDashboardEditNotifier>().isEditing;
//     return Transform.scale(
//       scale: 1,
//       child: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 Expanded(
//                   child: Dashboard<String>(
//                     controller: _controller,
//                     breakpoints: {
//                       0: 4,
//                       600: 8,
//                       1200: 12,
//                       1600: 16,
//                     },
//                     resizeBehavior: ResizeBehavior.shrink,
//                     padding: EdgeInsets.zero,
//                     mainAxisSpacing: 10,
//                     crossAxisSpacing: 10,
//                     resizeHandleSide: 24,
//                     showScrollbar: false,
//                     cacheExtent: 600,
//                     itemFeedbackBuilder: (context, item, child) {
//                       return Opacity(
//                         opacity: 0.75,
//                         child: Material(
//                           color: Colors.transparent,
//                           elevation: 8,
//                           borderRadius: BorderRadius.circular(16),
//                           child: child,
//                         ),
//                       );
//                     },
//                     itemBuilder: (context, item) {
//                       final homeWidget = HomeWidgetId.fromId(item.id);
//                       if (homeWidget == null) return const SizedBox.shrink();
//                       return KeyedSubtree(
//                         key: ValueKey(item.id),
//                         child: homeWidget.buildWidget(context),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (isEditing)
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: _HomeDashboardEditBar(
//                 onSave: () {
//                   _saveLayout();
//                   _editNotifier.setEditing(false);
//                 },
//                 onCancel: () {
//                   _cancelEdit();
//                   _editNotifier.setEditing(false);
//                 },
//                 onRestoreToDefault: () {
//                   _restoreToDefault();
//                   _editNotifier.setEditing(false);
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class _HomeDashboardEditBar extends StatelessWidget {
//   const _HomeDashboardEditBar({
//     required this.onSave,
//     required this.onCancel,
//     required this.onRestoreToDefault,
//   });

//   final VoidCallback onSave;
//   final VoidCallback onCancel;
//   final VoidCallback onRestoreToDefault;

//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context)!;
//     final theme = Theme.of(context);
//     return Material(
//       elevation: 8,
//       color: theme.colorScheme.surface,
//       child: SafeArea(
//         top: false,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               FilledButton.icon(
//                 onPressed: onSave,
//                 icon: const Icon(Icons.check_rounded, size: 20),
//                 label: Text(l10n.save),
//               ),
//               const SizedBox(width: 12),
//               OutlinedButton(
//                 onPressed: onCancel,
//                 child: Text(l10n.cancel),
//               ),
//               const SizedBox(width: 12),
//               OutlinedButton(
//                 onPressed: onRestoreToDefault,
//                 child: Text(l10n.default0),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Default positions (x, y, w, h) for each home widget id. Used to seed layout
// /// and when adding a widget back.
// const List<LayoutItem> defaultHomeDashboardLayout = [
//   LayoutItem(
//     id: 'upload',
//     x: 0,
//     y: 0,
//     w: 2,
//     h: 1,
//   ),
//   LayoutItem(
//     id: 'download',
//     x: 2,
//     y: 0,
//     w: 2,
//     h: 1,
//   ),
//   LayoutItem(
//     id: 'memory',
//     x: 4,
//     y: 0,
//     w: 2,
//     h: 1,
//   ),
//   LayoutItem(
//     id: 'connections',
//     x: 6,
//     y: 0,
//     w: 2,
//     h: 1,
//   ),
//   LayoutItem(
//     id: 'route',
//     x: 0,
//     y: 1,
//     w: 4,
//     h: 1,
//   ),
//   LayoutItem(
//     id: 'proxySelector',
//     x: 0,
//     y: 2,
//     w: 4,
//     h: 3,
//   ),
//   LayoutItem(
//     id: 'nodes',
//     x: 4,
//     y: 1,
//     w: 4,
//     h: 1,
//   ),
//   LayoutItem(
//     id: 'nodesHelper',
//     x: 2,
//     y: 3,
//     w: 2,
//     h: 4,
//   ),
//   LayoutItem(
//     id: 'inbound',
//     x: 0,
//     y: 6,
//     w: 2,
//     h: 2,
//   ),
//   LayoutItem(
//     id: 'subscription',
//     x: 2,
//     y: 7,
//     w: 2,
//     h: 2,
//   ),
//   LayoutItem(
//     id: 'promotion',
//     x: 0,
//     y: 8,
//     w: 4,
//     h: 3,
//   ),
// ];

// /// Notifier for home dashboard edit mode (drag/resize). Shared so the top bar
// /// can show the Edit/Save button when route is /home.
// class HomeDashboardEditNotifier extends ChangeNotifier {
//   bool _isEditing = false;
//   bool get isEditing => _isEditing;

//   void toggle() {
//     _isEditing = !_isEditing;
//     notifyListeners();
//   }

//   void setEditing(bool value) {
//     if (_isEditing == value) return;
//     _isEditing = value;
//     notifyListeners();
//   }
// }
