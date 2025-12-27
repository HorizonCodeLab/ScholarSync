import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cgpa_calc_controller.dart';
import '../models/subject_model.dart';

import '../../controllers/theme_controller.dart';

class CalculateCgpaScreen extends StatefulWidget {
  const CalculateCgpaScreen({super.key});

  @override
  State<CalculateCgpaScreen> createState() => _CalculateCgpaScreenState();
}

class _CalculateCgpaScreenState extends State<CalculateCgpaScreen> {


  final CgpaCalcController calcController = Get.find<CgpaCalcController>();
  final ThemeController themeController = Get.find<ThemeController>();


  int _selectedSemester = 1;

  List<SubjectModel> _subjectsForSem(List<SubjectModel> all, int sem) {
    return all.where((s) => s.semester == sem).toList();
  }

  // ------------------- BUILD -------------------

  @override
  Widget build(BuildContext context) {
    final palette = themeController.palette;

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        backgroundColor: palette.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.black),
        title: Text(
          "Calculate CGPA",
          style: TextStyle(
            fontSize: 22,
            color: palette.black,
            fontFamily: 'Righteous'
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Obx(() {
          final subjects = calcController.subjects;
          final gpaMap = calcController.gpaPerSem;
          final cgpa = calcController.cgpa.value;

          // Optimization: This sort is fine as semester subjects are usually few (<15)
          final subjectsForSem = _subjectsForSem(subjects, _selectedSemester);
          subjectsForSem.sort((a, b) => a.code.compareTo(b.code));

          return Column(
            children: [
              // TOP SUMMARY CARD
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  decoration: BoxDecoration(
                    color: palette.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // CGPA text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cgpa == 0.0 ? "--" : cgpa.toStringAsFixed(2),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 32,
                              color: palette.accent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Current CGPA",
                            style: TextStyle(
                              fontSize: 12,
                              color: palette.accent.withAlpha(150),
                            ),
                          ),
                        ],
                      ),

                      // Sem-wise GPA summary
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Semester $_selectedSemester GPA",
                            style: TextStyle(
                              fontSize: 12,
                              color: palette.accent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (gpaMap.isEmpty)
                            Text(
                              "No data",
                              style: TextStyle(fontSize: 12, color: palette.accent),
                            )
                          else
                            Text(
                              gpaMap[_selectedSemester]==null?"--":"${gpaMap[_selectedSemester]?.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: palette.accent
                              ),
                            )
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // SEMESTER CHIPS + ADD SUBJECT
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(8, (index) {
                            final sem = index + 1;
                            final isSelected = _selectedSemester == sem;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(
                                  "Sem $sem",
                                  style: TextStyle(fontSize: 12),
                                ),
                                selected: isSelected,
                                showCheckmark: false,
                                selectedColor: palette.primary,
                                backgroundColor: palette.black.withAlpha(20),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? palette.accent
                                      : palette.black,
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    _selectedSemester = sem;
                                  });
                                },
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _showAddSubjectOptions(
                        context,
                        _selectedSemester,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add, color: palette.accent),
                          const SizedBox(width: 4),
                          Text(
                            "Subject",
                            style: TextStyle(
                              color: palette.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // SUBJECT LIST
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: subjectsForSem.isEmpty
                      ? Center(
                          child: Text(
                            "No subjects for this semester.\nTap + to add.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: palette.black.withAlpha(150),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: subjectsForSem.length,
                          itemBuilder: (context, index) {
                            final subject = subjectsForSem[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: palette.accent,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                    color: palette.black.withAlpha(10),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // subject name & credits (and code)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          subject.code.isNotEmpty
                                              ? "${subject.code} - ${subject.name}"
                                              : subject.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: palette.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${subject.credits.toStringAsFixed(1)} credits",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: palette.black.withAlpha(150),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // grade dropdown
                                  SizedBox(
                                    width: 110,
                                    child: DropdownButtonFormField<String>(
                                      value: subject.grade.isEmpty
                                          ? null
                                          : subject.grade,
                                      items: calcController.gradePoints.keys
                                          .map(
                                            (g) => DropdownMenuItem(
                                              value: g,
                                              child: Text(g),
                                            ),
                                          )
                                          .toList(),
                                      hint: const Text("Grade"),
                                      onChanged: (val) {
                                        if (val != null) {
                                          calcController.updateSubjectGrade(
                                            subject,
                                            val,
                                          );
                                        }
                                      },
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        filled: true,
                                        fillColor: palette.black.withAlpha(20),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 4),

                                  // delete subject
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                      color: palette.error,
                                    ),
                                    onPressed: () {
                                      _showDeleteConfirmation(
                                        context,
                                        subject,
                                        palette,
                                      );
                                    },
                                  ),

                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    SubjectModel subject,
    palette,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: palette.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: palette.error),
              const SizedBox(width: 8),
              const Text(
                "Delete Subject?",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Text(
            "This subject will be removed from:\n\n"
            "• CGPA calculation\n"
            "• Internal marks page\n\n"
            "This action cannot be undone.",
            style: TextStyle(fontSize: 13, color: palette.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(color: palette.primary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop(); // close dialog

                await calcController.removeSubjectAndCleanup(subject);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "${subject.name} removed from CGPA & Internal Marks",
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------- SUBJECT PICKER (TEMPLATES) -------------------

  void _showSubjectPickerBottomSheet(BuildContext context, int semester) {
    // Local reactive variable for the search results
    // This decouples the search list from the global Obx
    final filteredSubjects = <SubjectModel>[].obs;
    
    // Initialize with all subjects sorted
    final allTemplates = calcController.templates;
    allTemplates.sort((a, b) => a.code.compareTo(b.code));
    filteredSubjects.assignAll(allTemplates);

    final palette = themeController.palette;


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Text(
                        "Choose Subject",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Search box
                  TextField(
                    onChanged: (val) {
                      final query = val.toLowerCase();
                      if (query.isEmpty) {
                        filteredSubjects.assignAll(allTemplates);
                      } else {
                        final results = allTemplates.where((s) {
                          final code = s.code.toLowerCase();
                          final name = s.name.toLowerCase();
                          return code.contains(query) || name.contains(query);
                        }).toList();
                        filteredSubjects.assignAll(results);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Search by code or name",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: palette.accent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // List of subjects
                  Expanded(
                    child: Obx(() {
                      if (filteredSubjects.isEmpty) {
                        return Center(
                          child: Text(
                            "No subjects found.\nTap 'Add new subject manually' instead.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: palette.black),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: filteredSubjects.length,
                        itemBuilder: (_, index) {
                          final subject = filteredSubjects[index];
                          final alreadyAdded = calcController.subjectExists(
                            code: subject.code,
                            semester: semester,
                          );


                          final displayCode = subject.code.isEmpty
                              ? "No Code"
                              : subject.code;

                          return Card(
                            color: palette.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                                enabled: !alreadyAdded,
                                title: Text(
                                  "$displayCode - ${subject.name}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: alreadyAdded ? palette.black.withAlpha(120) : palette.black,
                                  ),
                                ),
                                subtitle: Text(
                                  alreadyAdded
                                      ? "Already added to this semester"
                                      : "${subject.credits.toStringAsFixed(1)} credits",
                                  style: TextStyle(fontSize: 12),
                                ),
                                trailing: alreadyAdded
                                    ? const Icon(Icons.check_circle, color: Colors.green)
                                    : null,
                                onTap: alreadyAdded
                                    ? null
                                    : () async {
                                        await calcController.addSubjectFromTemplate(
                                          subject,
                                          semester,
                                        );
                                        await calcController.recalculateAll();
                                        if (context.mounted) Navigator.of(ctx).pop();
                                      },
                              )

                          );
                        },
                      );
                    }),
                  ),

                  const SizedBox(height: 8),

                  // Add new button at bottom
                  Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _showAddSubjectDialog(context, semester);
                      },
                      icon: Icon(
                        Icons.add,
                        size: 18,
                        color: palette.primary,
                      ),
                      label: Text(
                        "Can't find your subject? Add manually",
                        style: TextStyle(color: palette.primary),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ------------------- DEPT-BASED SUBJECT PICKER (OPTIMIZED) -------------------

  void _showDeptBasedSubjectPicker(BuildContext context, int semester) {
    // UI values for regulations & departments
    final regs = ['2021', '2025'];
    final depts = [
      {'code': 'CB', 'label': 'CSBS'},
      {'code': 'CS', 'label': 'CSE'},
      {'code': 'AD', 'label': 'AIDS'},
    ];

    final selectedReg = RxnString();
    final selectedDeptCode = RxnString();
    
    // Using a Set for faster lookups (O(1)) instead of List (O(N))
    final selectedCodes = <String>{}.obs; 
    
    // Separate List for the filtered subjects to avoid re-filtering on selection
    final filteredSubjects = <SubjectModel>[].obs;

    final palette = themeController.palette;


    // Helper to run the heavy filter logic
    void updateFilteredList() {
      final reg = selectedReg.value;
      final deptCode = selectedDeptCode.value;

      if (reg == null || deptCode == null) {
        filteredSubjects.clear();
        return;
      }

      final templates = calcController.templates;
      final filtered = templates.where((s) {
        return calcController.subjectMatchesMeta(
          s,
          regulation: reg,
          department: deptCode,
          semester: semester,
        );
      }).toList()
        ..sort((a, b) => a.code.compareTo(b.code));
      
      filteredSubjects.assignAll(filtered);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Text(
                        "Choose by Department",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Regulation dropdown
                  Obx(() {
                    return DropdownButtonFormField<String>(
                      value: selectedReg.value,
                      decoration: InputDecoration(
                        labelText: "Regulation",
                        labelStyle: TextStyle(fontSize: 13),
                        filled: true,
                        fillColor: palette.accent,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: regs
                          .map((r) => DropdownMenuItem(value: r, child: Text("Reg $r")))
                          .toList(),
                      onChanged: (val) {
                        selectedReg.value = val;
                        selectedCodes.clear();
                        updateFilteredList(); // Only filter when dropdown changes
                      },
                    );
                  }),
                  const SizedBox(height: 10),

                  // Department dropdown
                  Obx(() {
                    return DropdownButtonFormField<String>(
                      value: selectedDeptCode.value,
                      decoration: InputDecoration(
                        labelText: "Department",
                        labelStyle: TextStyle(fontSize: 13, color: palette.black),
                        filled: true,
                        fillColor: palette.accent,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: depts
                          .map((d) => DropdownMenuItem(value: d['code'], child: Text(d['label']!)))
                          .toList(),
                      onChanged: (val) {
                        selectedDeptCode.value = val;
                        selectedCodes.clear();
                        updateFilteredList(); // Only filter when dropdown changes
                      },
                    );
                  }),
                  const SizedBox(height: 12),

                  // Subject list
                  Expanded(
                    // This Obx now ONLY listens to filteredSubjects (list changes), 
                    // NOT selections.
                    child: Obx(() {
                      if (selectedReg.value == null || selectedDeptCode.value == null) {
                         return Center(
                          child: Text(
                            "Select regulation and department to view subjects\nfor Sem $semester",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: palette.black),
                          ),
                        );
                      }

                      if (filteredSubjects.isEmpty) {
                        return Center(
                          child: Text(
                            "No subjects mapped for this combination.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: palette.black),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: filteredSubjects.length,
                        itemBuilder: (_, index) {
                          final subject = filteredSubjects[index];
                          final code = subject.code;
                          final alreadyAdded = calcController.subjectExists(
                            code: subject.code,
                            semester: semester,
                          );


                          return Card(
                            color: palette.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            // Optimization: Only this specific tile rebuilds when ticked
                            child: Obx(() {
                              //final isSelected = selectedCodes.contains(code);
                              return CheckboxListTile(
                                value: selectedCodes.contains(code),
                                onChanged: alreadyAdded
                                    ? null
                                    : (val) {
                                        if (val == true) {
                                          selectedCodes.add(code);
                                        } else {
                                          selectedCodes.remove(code);
                                        }
                                      },
                                title: Text(
                                  "${subject.code} - ${subject.name}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: alreadyAdded ? palette.black.withAlpha(120) : palette.black,
                                  ),
                                ),
                                subtitle: Text(
                                  alreadyAdded
                                      ? "Already added"
                                      : "${subject.credits.toStringAsFixed(1)} credits",
                                  style: TextStyle(fontSize: 12),
                                ),
                              );
                            }),
                          );
                        },
                      );
                    }),
                  ),

                  const SizedBox(height: 8),

                  // Add selected button
                  Obx(() {
                    final hasSelection = selectedCodes.isNotEmpty;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              hasSelection ? palette.primary : palette.black.withAlpha(150),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 10,
                          ),
                        ),
                        onPressed: hasSelection
                            ? () async {
                                final reg = selectedReg.value;
                                final deptCode = selectedDeptCode.value;
                                if (reg == null || deptCode == null) return;

                                // Helper to identify selected objects
                                final toAdd = filteredSubjects.where((s) {
                                  return selectedCodes.contains(s.code);
                                }).toList();

                                Navigator.of(ctx).pop(); // Close UI immediately to feel snappy

                                // Process in background
                                for (final t in toAdd) {
                                  await calcController.addSubjectFromTemplate(
                                    t,
                                    semester,
                                  );
                                }
                                await calcController.recalculateAll();

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Added ${toAdd.length} subject(s) to Sem $semester",
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        child: Text(
                          hasSelection
                              ? "Add selected subjects"
                              : "Select subjects to add",
                          style: TextStyle(color: palette.accent),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ------------------- ADD SUBJECT OPTIONS SHEET -------------------

  void _showAddSubjectOptions(BuildContext context, int semester) {
    final palette = themeController.palette;
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Add subject to semester",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.account_tree_outlined),
                title: const Text("Choose using department"),
                subtitle: const Text(
                  "Regulation • Department • Multi-select",
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showDeptBasedSubjectPicker(context, semester);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.list_alt_outlined),
                title: const Text("Choose from subject list"),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showSubjectPickerBottomSheet(context, semester);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text("Add new subject manually"),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showAddSubjectDialog(context, semester);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------- ADD SUBJECT DIALOG (MANUAL) -------------------

  void _showAddSubjectDialog(BuildContext context, int semester) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final creditsCtrl = TextEditingController();
    final palette = themeController.palette;
    final isDuplicate = false.obs;

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
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Add Subject",
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
                  const SizedBox(height: 10),

                  // Subject code
                  TextField(
                    controller: codeCtrl,
                    onChanged: (val) {
                      isDuplicate.value = calcController.subjectExists(
                        code: val,
                        semester: semester,
                      );
                    },
                    decoration: InputDecoration(
                      labelText: "Subject Code",
                      errorText: isDuplicate.value ? "Subject already exists" : null,
                      prefixIcon: const Icon(Icons.qr_code_2),
                      filled: true,
                      fillColor: palette.accent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Subject name
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: "Subject Name",
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      prefixIcon: const Icon(Icons.menu_book_outlined),
                      filled: true,
                      fillColor: palette.accent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Credits
                  TextField(
                    controller: creditsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Credits",
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      prefixIcon: const Icon(Icons.numbers),
                      filled: true,
                      fillColor: palette.accent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Buttons
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
                      Obx((){
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDuplicate.value
                              ? palette.black.withAlpha(150)
                              : palette.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isDuplicate.value
                            ? null: () async {
                            final name = nameCtrl.text.trim();
                            final code = codeCtrl.text.trim();
                            final creditsStr = creditsCtrl.text.trim();
                            final grade = "O";

                            if (name.isEmpty ||
                                code.isEmpty ||
                                creditsStr.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Code, name and credits are required",
                                  ),
                                ),
                              );
                              return;
                            }

                            final credits = double.tryParse(creditsStr) ?? 0;
                            if (credits <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Credits must be > 0"),
                                ),
                              );
                              return;
                            }

                            await calcController.addSubject(
                              name: name,
                              code: code,
                              credits: credits,
                              semester: semester,
                              grade: grade.isEmpty ? "" : grade,
                            );

                            if (context.mounted) Navigator.of(ctx).pop();
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
                        );
                      })
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
}