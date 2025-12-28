import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/course_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/ad_controller.dart';

import '../models/course_model.dart';

class CourseScreen extends StatelessWidget {
  final CourseController courseController = Get.put(CourseController());
  final ThemeController themeController = Get.find<ThemeController>();
  final AdController adController = Get.find<AdController>();

  CourseScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final palette = themeController.palette;

    return Scaffold(
      backgroundColor: palette.bg,

      // ---------- FAB ADD BUTTON ----------
      floatingActionButton: SizedBox(
        height: 56,
        width: 56,
        child: FloatingActionButton(
          heroTag: 'course_screen_fab',
          onPressed: () => _showAddCourseDialog(context),
          backgroundColor: palette.primary,
          child: Icon(Icons.add, color: palette.accent),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Title ----
              Text(
                "Course Manager",
                style: TextStyle(
                  fontSize: 22,
                  color: palette.minimal,
                  fontFamily: 'Righteous',

                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Track your learning & certificates",
                style: TextStyle(
                  fontSize: 12,
                  color: palette.black.withAlpha(150),
                ),
              ),

              const SizedBox(height: 18),

              // ---- Stats card (Completed / Pending) ----
              Obx(() {
                final completed = courseController.completedCount;
                final pending = courseController.pendingCount;

                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                  decoration: BoxDecoration(
                    color: palette.primary,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                        color: palette.black.withAlpha(10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "$completed",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: palette.accent
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Completed",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: palette.accent
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1.5,
                        height: 50,
                        color: palette.accent,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "$pending",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: palette.accent
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Pending",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: palette.accent
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 22),

              // ---- Filter row: status + categories + +Category ----
              Obx(() {
                final current = courseController.selectedFilter.value;
                final categories = courseController.categoryList;

                Widget buildFilterChip(String label) {
                  final isSelected = current == label;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      showCheckmark: false,
                      backgroundColor: palette.black.withAlpha(20),
                      selectedColor: palette.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? palette.accent : palette.black,
                      ),
                      onSelected: (_) =>
                          courseController.selectedFilter.value = label,
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      buildFilterChip('All'),
                      buildFilterChip('Completed'),
                      buildFilterChip('Pending'),
                      ...categories.map(buildFilterChip).toList(),
                      GestureDetector(
                        onTap: () => _showAddCategoryDialog(context),
                        child: Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: palette.secondary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add,
                                  size: 16, color: palette.black),
                              SizedBox(width: 4),
                              Text(
                                "Category",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: palette.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 18),

              // ---- Course list ----
              Expanded(
                child: Obx(() {
                  final courses = courseController.filteredCourses;

                  if (courses.isEmpty) {
                    return Center(
                      child: Text(
                        "No courses yet.\nTap + to add one.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: palette.black.withAlpha(150),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      final originalIndex =
                          courseController.courseList.indexOf(course);

                      return GestureDetector(
                        onTap: () => _showEditCourseDialog(
                            context, course, originalIndex),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                        
                          decoration: BoxDecoration(
                            color: palette.accent,
                            borderRadius: BorderRadius.circular(16),
                            
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 6,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                                color: palette.black.withAlpha(10),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Thumbnail (certificate preview)
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: palette.bg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: _buildCertificatePreview(
                                  course.certificationPath,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Text content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    
                                    Text(
                                      course.courseName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      course.courseDescription,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: palette.black.withAlpha(150),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    
                                  ],
                                  
                                ),
                                
                              ),
                              Column(
                                children: [

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          course.isCompleted
                                              ? Icons.check_circle_outline
                                              : Icons.pending_outlined,
                                          size: 16,
                                          color: course.isCompleted
                                              ? palette.success
                                              : palette.warning,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          course.isCompleted
                                              ? "Completed"
                                              : "Pending",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: course.isCompleted
                                                ? palette.success
                                                : palette.warning,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                  ),
                                  
                                  Row(
                                      children: [
                                        if (course.certificationPath.isNotEmpty)
                                          IconButton(
                                            
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(Icons.download, size: 20),
                                            tooltip: "Download certificate",
                                            onPressed: () => _downloadCertificate(
                                              context,
                                              course.certificationPath,
                                            ),
                                          ),
                                          Icon(Icons.chevron_right, size: 20), 
                                          
                                      ],
                                    ),
                                ],
                              )
                              


                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================== CERTIFICATE PREVIEW ==================
  Widget _buildCertificatePreview(String path) {
    final palette = themeController.palette;

    if (path.isEmpty) {
      return Icon(Icons.insert_drive_file, color: palette.black.withAlpha(150));
    }

    final ext = path.split('.').last.toLowerCase();

    if (ext == 'png' || ext == 'jpg' || ext == 'jpeg') {
      final file = File(path);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            file,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    if (ext == 'pdf') {
      return Icon(
        Icons.picture_as_pdf,
        color: palette.error,
        size: 32,
      );
    }

    return Icon(Icons.insert_drive_file, color: palette.black.withAlpha(150));
  }

  // ================== ADD COURSE DIALOG ==================
  void _showAddCourseDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final certPathController = TextEditingController();
    final isCompleted = false.obs;
    final selectedFileName = ''.obs;
    final selectedCategories = <String>[].obs;
    final palette = themeController.palette;

    Future<void> _pickCertificate() async {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          withData: false, // important for large files
        );

        if (result == null || result.files.isEmpty) return;

        final file = result.files.single;

        if (file.path == null) return;

        certPathController.text = file.path!;
        selectedFileName.value = file.name;
      } catch (e) {
        debugPrint("FilePicker error: $e");
      }
    }



    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: palette.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Add Course",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Course name
                  TextField(
                    controller: nameController,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: "Course name",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      prefixIcon: const Icon(Icons.menu_book_outlined, size: 22,),
                      filled: true,
                      fillColor: palette.black.withAlpha(10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Description
                  Container(
                    decoration: BoxDecoration(
                      color: palette.black.withAlpha(10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon aligned with first text line (NOT label)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.description_outlined,
                            size: 22,
                            color: palette.black.withAlpha(160),
                          ),
                        ),
                        const SizedBox(width: 10),

                        Expanded(
                          child: TextField(
                            controller: descController,
                            maxLines: 3,
                            textAlignVertical: TextAlignVertical.top,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: "Course description",
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10),

                  // Upload certificate
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Certificate (optional)",
                          style: TextStyle(
                            fontSize: 13,
                            color: palette.black.withAlpha(150),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FilledButton.icon(
                          onPressed: _pickCertificate,
                          style: FilledButton.styleFrom(
                            backgroundColor: palette.primary,
                            foregroundColor: palette.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          icon: const Icon(Icons.upload_file),
                          label: Text(
                            selectedFileName.isEmpty
                                ? "Upload certificate"
                                : selectedFileName.value,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Categories multi-select
                  Obx(() {
                    final categories = courseController.categoryList;

                    if (categories.isEmpty) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Categories",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showAddCategoryDialog(context),
                            icon: Icon(Icons.add,
                                size: 16, color: palette.primary),
                            label: Text(
                              "Add category",
                              style: TextStyle(color: palette.primary),
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Categories",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showAddCategoryDialog(context),
                              icon: Icon(Icons.add,
                                  size: 16, color: palette.primary),
                              label: Text(
                                "New",
                                style: TextStyle(color: palette.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: categories.map((cat) {
                            final isSelected =
                                selectedCategories.contains(cat);
                            return ChoiceChip(
                              backgroundColor: palette.black.withAlpha(20),
                              selectedColor: palette.secondary,
                              label: Text(cat),
                              showCheckmark: false,
                              selected: isSelected,
                              onSelected: (val) {
                                if (val) {
                                  selectedCategories.add(cat);
                                } else {
                                  selectedCategories.remove(cat);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 6),

                  // Completed switch
                  Obx(
                    () => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "Completed",
                        style: TextStyle(fontSize: 14),
                      ),
                      value: isCompleted.value,
                      activeColor: palette.accent,
                      activeTrackColor: palette.primary,
                      onChanged: (val) => isCompleted.value = val,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: palette.primary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: palette.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Course name cannot be empty")),
                            );
                            return;
                          }

                          final course = CourseModel(
                            courseName: nameController.text.trim(),
                            isCompleted: isCompleted.value,
                            certificationPath: certPathController.text.trim(),
                            courseDescription: descController.text.trim(),
                            categories: selectedCategories.toList(),
                          );

                          // 👇 OPTIONAL SUPPORT AD
                          adController.showRewarded(() {
                            courseController.addCourse(course);
                            Navigator.of(ctx).pop();
                          });
                        },

                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Text(
                            "Save",
                            style: TextStyle(color: palette.accent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= DOWNLOAD COURSE CERTIFICATE ==================

  Future<void> _downloadCertificate(
    BuildContext context,
    String sourcePath,
  ) async {
    try {
      if (sourcePath.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No certificate available")),
        );
        return;
      }

      final sourceFile = File(sourcePath);
      if (!sourceFile.existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Certificate file not found")),
        );
        return;
      }

      final fileName = p.basename(sourcePath);

      // 🔥 READ FILE AS BYTES (REQUIRED)
      final bytes = await sourceFile.readAsBytes();

      // 🔥 SYSTEM SAVE DIALOG
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Download certificate',
        fileName: fileName,
        bytes: bytes, // ✅ THIS FIXES THE ERROR
      );

      if (savePath == null) return; // user cancelled

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Certificate downloaded successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e")),
      );
    }
  }




  // ================== EDIT COURSE DIALOG ==================
  void _showEditCourseDialog(
    BuildContext context,
    CourseModel course,
    int index,
  ) {
    final nameController = TextEditingController(text: course.courseName);
    final descController =
        TextEditingController(text: course.courseDescription);
    final certPathController =
        TextEditingController(text: course.certificationPath);
    final isCompleted = course.isCompleted.obs;
    final selectedCategories = (course.categories).toList().obs;

    final selectedFileName = (course.certificationPath.isNotEmpty
        ? p.basename(course.certificationPath)
        : '')
    .obs;


    Future<void> _pickCertificate() async {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          withData: false,
        );

        if (result == null || result.files.isEmpty) return;

        final file = result.files.single;

        if (file.path == null) return;  

        certPathController.text = file.path!;
        selectedFileName.value = file.name;
      } catch (e) {
        debugPrint("FilePicker error: $e");
      }
    }


    final palette = themeController.palette;



    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: palette.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Edit Course",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Course name
                  TextField(
                    controller: nameController,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: "Course name",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      prefixIcon: const Icon(Icons.menu_book_outlined, size: 22,),
                      filled: true,
                      fillColor: palette.black.withAlpha(10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Description
                  Container(
                    decoration: BoxDecoration(
                      color: palette.black.withAlpha(10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon aligned with first text line (NOT label)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.description_outlined,
                            size: 22,
                            color: palette.black.withAlpha(160),
                          ),
                        ),
                        const SizedBox(width: 10),

                        Expanded(
                          child: TextField(
                            controller: descController,
                            maxLines: 3,
                            textAlignVertical: TextAlignVertical.top,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: "Course description",
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Upload certificate
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Certificate (optional)",
                          style: TextStyle(
                            fontSize: 13,
                            color: palette.black.withAlpha(150),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: palette.primary,
                            foregroundColor: palette.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          onPressed: _pickCertificate,
                          icon: const Icon(Icons.upload_file),
                          label: Text(
                            selectedFileName.isEmpty
                                ? "Upload / Change certificate"
                                : selectedFileName.value,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Categories multi-select
                  Obx(() {
                    final categories = courseController.categoryList;

                    if (categories.isEmpty) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Categories",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showAddCategoryDialog(context),
                            icon: Icon(Icons.add,
                                size: 16, color: palette.primary),
                            label: Text(
                              "Add category",
                              style: TextStyle(color: palette.primary),
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Categories",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showAddCategoryDialog(context),
                              icon: Icon(Icons.add,
                                  size: 16, color: palette.primary),
                              label: Text(
                                "New",
                                style: TextStyle(color: palette.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: categories.map((cat) {
                            final isSelected =
                                selectedCategories.contains(cat);
                            return ChoiceChip(
                              backgroundColor: palette.black.withAlpha(20),
                              selectedColor: palette.secondary,
                              label: Text(cat),
                              showCheckmark: false,
                              selected: isSelected,
                              onSelected: (val) {
                                if (val) {
                                  selectedCategories.add(cat);
                                } else {
                                  selectedCategories.remove(cat);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 6),

                  // Completed switch
                  Obx(
                    () => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "Completed",
                        style: TextStyle(fontSize: 14),
                      ),
                      activeColor: palette.accent,
                      activeTrackColor: palette.primary,
                      value: isCompleted.value,
                      onChanged: (val) => isCompleted.value = val,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Buttons row: Delete + Update
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Delete
                      TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (confirmCtx) => Dialog(
                              backgroundColor: palette.bg,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    20, 18, 20, 12),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.warning_amber_rounded, color: palette.error),
                                            const SizedBox(width: 8),
                                            const Text(
                                              "Delete Course?",
                                              style: TextStyle(fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () =>
                                              Navigator.of(confirmCtx).pop(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Are you sure you want to delete this course? This action cannot be undone.",
                                      style: TextStyle(fontSize: 13, color: palette.black),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(confirmCtx).pop(),
                                          child: Text(
                                            "Cancel",
                                            style:
                                                TextStyle(color: palette.primary),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            courseController
                                                .deleteCourse(index);
                                            Navigator.of(confirmCtx).pop();
                                            Navigator.of(ctx).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: palette.error,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            "Delete",
                                            style:
                                                TextStyle(color: palette.accent),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.delete_outline,
                          color: palette.error,
                        ),
                        label: Text(
                          "Delete",
                          style: TextStyle(color: palette.error),
                        ),
                      ),

                      Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: palette.primary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: palette.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              if (nameController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Course name cannot be empty")),
                                );
                                return;
                              }

                              final updatedCourse = CourseModel(
                                courseName: nameController.text.trim(),
                                isCompleted: isCompleted.value,
                                certificationPath: certPathController.text.trim(),
                                courseDescription: descController.text.trim(),
                                categories: selectedCategories.toList(),
                              );

                              _showSupportAdDialog(() {
                                courseController.updateCourse(index, updatedCourse);
                                Navigator.of(ctx).pop();
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              child: Text(
                                "Update",
                                style: TextStyle(color: palette.accent),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSupportAdDialog(VoidCallback onContinue) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ❌ Close button (top-left)
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  splashRadius: 20,
                  onPressed: () {
                    Get.back();       // close dialog
                    onContinue();     // continue without ad
                  },
                ),
              ),

              const SizedBox(height: 4),

              // 🎯 Title
              const Center(
                child: Text(
                  "Support the App",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 📝 Description
              const Center(
                child: Text(
                  "Watch a short ad to support development and keep the app free.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ▶ Watch Ad button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    adController.showRewarded(onContinue);
                  },
                  icon: const Icon(Icons.play_circle_fill),
                  label: const Text("Watch Ad"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true, // tap outside also skips
    );
  }



  // ================== ADD CATEGORY DIALOG ==================
  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    final palette = themeController.palette;

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: palette.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "New Category",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: "Category name",
                    filled: true,
                    fillColor: palette.black.withAlpha(10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: palette.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final name = controller.text.trim();
                        if (name.isNotEmpty) {
                          courseController.addCategory(name);
                        }
                        Navigator.of(ctx).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Add",
                        style: TextStyle(color: palette.accent),
                      ),
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
}
