 import 'package:flutter/material.dart';
 import 'package:provider/provider.dart';
 import '../../shared/constants.dart';
 import 'camera_viewmodel.dart';
import '../../models/filter_preset.dart';
 
 class CameraToolbar extends StatelessWidget {
   const CameraToolbar({super.key});
 
   @override
   Widget build(BuildContext context) {
     return Consumer<CameraViewModel>(
       builder: (context, vm, child) {
         return Container(
           padding: const EdgeInsets.only(bottom: 32, left: 24, right: 24),
           decoration: const BoxDecoration(
             gradient: LinearGradient(
               begin: Alignment.topCenter,
               end: Alignment.bottomCenter,
               colors: [Colors.transparent, Colors.black54],
             ),
           ),
           child: SafeArea(
             top: false,
             child: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                 // Filter strip
                 if (vm.showFilterPanel) _buildFilterStrip(context, vm),
                 const SizedBox(height: 16),
                 // Main controls
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: [
                     // Album button
                     IconButton(
                       icon: const Icon(Icons.photo_library_outlined),
                       color: Colors.white,
                       iconSize: 28,
                       onPressed: () => Navigator.pushNamed(context, '/album'),
                     ),
                     // Composition button
                     _buildModeButton(
                       icon: Icons.auto_fix_high,
                       label: '???',
                       isActive: vm.mode == CameraMode.composition,
                       onTap: () => vm.setMode(
                         vm.mode == CameraMode.composition
                             ? CameraMode.normal
                             : CameraMode.composition,
                       ),
                     ),
                     // Shutter button
                     _buildShutterButton(context, vm),
                     // Filter button
                     _buildModeButton(
                       icon: Icons.filter_vintage,
                       label: '???',
                       isActive: vm.showFilterPanel,
                       onTap: vm.toggleFilterPanel,
                     ),
                     // Camera switch
                                          // Scheme switch
                     if (vm.mode == CameraMode.composition) 
                       _buildModeButton(
                         icon: Icons.swap_horiz,
                         label: vm.compositionResult?.ruleLabel ?? '构图',
                         isActive: false,
                         onTap: vm.switchCompositionScheme,
                       ),
                     IconButton(
                       icon: const Icon(Icons.flip_camera_android),
                       color: Colors.white,
                       iconSize: 28,
                       onPressed: () => vm.cameraService.switchCamera(),
                     ),
                   ],
                 ),
               ],
             ),
           ),
         );
       },
     );
   }
 
   Widget _buildShutterButton(BuildContext context, CameraViewModel vm) {
     return GestureDetector(
       onTap: () => vm.takePhoto(),
       child: Container(
         width: 72,
         height: 72,
         decoration: BoxDecoration(
           shape: BoxShape.circle,
           border: Border.all(color: DokaColors.shutterRing, width: 4),
           color: DokaColors.shutter.withValues(alpha: 0.9),
         ),
         child: Center(
           child: Container(
             width: 60,
             height: 60,
             decoration: const BoxDecoration(
               shape: BoxShape.circle,
               color: DokaColors.shutter,
             ),
           ),
         ),
       ),
     );
   }
 
   Widget _buildModeButton({
     required IconData icon,
     required String label,
     required bool isActive,
     required VoidCallback onTap,
   }) {
     return GestureDetector(
       onTap: onTap,
       child: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           Container(
             padding: const EdgeInsets.all(10),
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               color: isActive ? Colors.white.withValues(alpha: 0.3) : Colors.transparent,
             ),
             child: Icon(icon, color: isActive ? Colors.white : Colors.white70, size: 24),
           ),
           const SizedBox(height: 4),
           Text(label, style: TextStyle(
             color: isActive ? Colors.white : Colors.white60,
             fontSize: 11,
           )),
         ],
       ),
     );
   }
 
   Widget _buildFilterStrip(BuildContext context, CameraViewModel vm) {
     final filters = vm.recommendedFilters.isNotEmpty
         ? vm.recommendedFilters
         : FilterPreset.builtIn;
     return SizedBox(
       height: 80,
       child: ListView.separated(
         scrollDirection: Axis.horizontal,
         padding: const EdgeInsets.symmetric(horizontal: 16),
         itemCount: filters.length,
         separatorBuilder: (_, __) => const SizedBox(width: 12),
         itemBuilder: (context, index) {
           final filter = filters[index];
           final isSelected = vm.selectedFilter?.name == filter.name;
           return GestureDetector(
             onTap: () => vm.selectFilter(filter),
             child: Column(
               children: [
                 Container(
                   width: 56,
                   height: 56,
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(8),
                     border: Border.all(
                       color: isSelected ? Colors.white : Colors.white24,
                       width: isSelected ? 2 : 1,
                     ),
                     color: Colors.grey[800],
                   ),
                   child: Center(
                     child: Icon(Icons.filter_vintage,
                       color: isSelected ? Colors.white : Colors.white38, size: 24),
                   ),
                 ),
                 const SizedBox(height: 4),
                 Text(filter.displayName,
                   style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : Colors.white60),
                 ),
               ],
             ),
           );
         },
       ),
     );
   }
 }


