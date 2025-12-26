import 'dart:async'; // Added for Debouncer
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Assuming these exist based on your upload
import '../../controllers/cgpa_calc_controller.dart';
import '../../controllers/internal_calc_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/subject_model.dart';

class CalculateInternalScreen extends StatefulWidget {
  const CalculateInternalScreen({super.key});

  @override
  State<CalculateInternalScreen> createState() =>
      _CalculateInternalScreenState();
}

class _CalculateInternalScreenState extends State<CalculateInternalScreen> {
  // Controllers
  final InternalCalcController internalCtrl = Get.find<InternalCalcController>();
  final CgpaCalcController cgpaCtrl = Get.find<CgpaCalcController>();
  final CgpaCalcController calcController = Get.find<CgpaCalcController>();
  final ThemeController themeController = Get.find<ThemeController>();

  // Local State
  int selectedSemester = 1;
  int selectedInternalNo = 1;
  
  // Optimization: Loading state to prevent lag on screen open
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // OPTIMIZATION: Delay the heavy rendering slightly to allow the 
    // navigation transition to finish smoothly.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = themeController.palette;

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        backgroundColor: palette.bg,
        iconTheme: IconThemeData(color: palette.black),
        title: Text(
          "Internal Exam Calculation",
          style: TextStyle(
            fontSize: 20,
            color: palette.minimal,
          ),
        ),
      ),
      // OPTIMIZATION: Show loader initially to fix "Lag on Open"
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: palette.primary))
          : Column(
              children: [
                // 1. Semester Summary Card (Scoped Obx inside)
                _buildSemesterSummaryCard(palette),

                // 2. Top Summary Card (Scoped Obx inside)
                _buildTopSummaryCard(palette),

                // 3. Semester Chips (No Obx needed for the list generation itself)
                _buildSemesterChips(palette),

                const SizedBox(height: 6),

                // 4. Internal Chips (Wrapped in Obx locally)
                _buildInternalChips(palette),

                const SizedBox(height: 12),

                // 5. Subject List (Heavy lifting isolated here)
                Expanded(
                  child: _SubjectListSection(
                    semester: selectedSemester,
                    internalNo: selectedInternalNo,
                    palette: palette,
                  ),
                ),
              ],
            ),
    );
  }

  // ---------------- WIDGET EXTRACTION FOR PERFORMANCE ----------------

  Widget _buildSemesterSummaryCard(dynamic palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: palette.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        // OPTIMIZATION: Only this widget rebuilds when calculation changes
        child: Obx(() {
          final semesterSummary = internalCtrl.getSemesterSummary(selectedSemester);
          final avgGpa = semesterSummary['avgGpa']!;
          final avgObtained = semesterSummary['avgObtained']!;
          final avgMax = semesterSummary['avgMax']!;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ---- Average GPA ----
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    avgGpa == 0 ? "--" : avgGpa.toStringAsFixed(2),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                      color: palette.accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Average GPA (Sem $selectedSemester)",
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.accent,
                    ),
                  ),
                ],
              ),
              // ---- Average Marks ----
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        avgObtained == 0 ? "--" : avgObtained.toStringAsFixed(0),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          color: palette.accent,
                        ),
                      ),
                      Text(
                        avgMax == 0 ? "" : " / ${avgMax.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: palette.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Avg Total Marks",
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.accent,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTopSummaryCard(dynamic palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: palette.secondary,
          borderRadius: BorderRadius.circular(16),
        ),
        // OPTIMIZATION: Scoped Obx
        child: Obx(() {
          final totalMarks = internalCtrl.getTotalMarks(
            semester: selectedSemester,
            internalNo: selectedInternalNo,
          );
          final obtained = totalMarks['obtained']!;
          final max = totalMarks['max']!;

          final gpa = internalCtrl.gpas.firstWhereOrNull(
            (g) =>
                g.semester == selectedSemester &&
                g.internalNo == selectedInternalNo,
          )?.gpa;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gpa == null ? "--" : gpa.toStringAsFixed(2),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 32,
                      color: palette.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "GPA of Sem $selectedSemester - IAT $selectedInternalNo",
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.black,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        obtained.toStringAsFixed(0),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: palette.primary,
                        ),
                      ),
                      Text(
                        " / ${max.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: palette.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Total Marks",
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.black,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSemesterChips(dynamic palette) {
    // No Obx here because list length 8 is constant
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(8, (i) {
            final sem = i + 1;
            final isSemSelected = sem == selectedSemester;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text("Sem $sem"),
                selected: isSemSelected,
                showCheckmark: false,
                selectedColor: palette.primary,
                backgroundColor: palette.black.withAlpha(20),
                labelStyle: TextStyle(
                  color: isSemSelected ? palette.accent : palette.black,
                ),
                onSelected: (_) {
                  setState(() {
                    selectedSemester = sem;
                    selectedInternalNo = 1;
                  });
                  internalCtrl.ensureDefaultInternals(sem);
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInternalChips(dynamic palette) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              // OPTIMIZATION: Only listen to changes in internals list
              child: Obx(() {
                final internals = internalCtrl.internals
                    .where((i) => i.semester == selectedSemester)
                    .toList();
                    
                return Row(
                  children: internals.map((i) {
                    final isSelected = i.internalNo == selectedInternalNo;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(i.name),
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: palette.secondary,
                        backgroundColor: palette.black.withAlpha(20),
                        labelStyle: TextStyle(
                          color: isSelected ? palette.primary : palette.black,
                        ),
                        onSelected: (_) {
                          setState(() {
                            selectedInternalNo = i.internalNo;
                          });
                        },
                      ),
                    );
                  }).toList(),
                );
              }),
            ),
          ),
          Row(
            children: [
              IconButton(
                tooltip: "Add Internal",
                onPressed: () => _showAddInternalDialog(context),
                icon: const Icon(Icons.playlist_add),
              ),
              IconButton(
                tooltip: "Add Subject",
                onPressed: () => _showAddSubjectOptions(context, selectedSemester),
                icon: Icon(Icons.add, color: palette.accent),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(palette.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------- POPUPS & DIALOGS -------------------

  // OPTIMIZED SUBJECT PICKER WITH DEBOUNCE
  void _showSubjectPickerBottomSheet(BuildContext context, int semester) {
    final searchText = ''.obs;
    final palette = themeController.palette;
    
    // Timer for debouncing
    Timer? _debounce;

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
                    // OPTIMIZATION: Debounce search input to prevent filtering huge lists on every keystroke
                    onChanged: (val) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 400), () {
                        searchText.value = val;
                      });
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
                      final templates = calcController.templates;
                      final query = searchText.value.toLowerCase();

                      // OPTIMIZATION: If list is empty/loading, return early
                      if (templates.isEmpty) return const SizedBox();

                      final filtered = templates.where((s) {
                        final code = s.code.toLowerCase();
                        final name = s.name.toLowerCase();
                        if (query.isEmpty) return true;
                        return code.contains(query) || name.contains(query);
                      }).toList();
                      
                      // OPTIMIZATION: Move sort logic. Ideally, templates should be pre-sorted in controller.
                      // If list is > 1000, sorting here is still heavy but debouncing helps.
                      filtered.sort((a, b) => a.code.compareTo(b.code));

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text(
                            "No subjects found.\nTap 'Add new subject manually' instead.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: filtered.length,
                        // OPTIMIZATION: Use itemExtent if height is fixed for better scrolling performance
                        // itemExtent: 70, 
                        itemBuilder: (_, index) {
                          final subject = filtered[index];
                          final displayCode = subject.code.isEmpty ? "No Code" : subject.code;

                          return Card(
                            color: palette.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                "$displayCode - ${subject.name}",
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                "${subject.credits.toStringAsFixed(1)} credits",
                                style: const TextStyle(fontSize: 12),
                              ),
                              onTap: () async {
                                if (subject.code.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("This template has no course code. Please edit/add it manually."),
                                    ),
                                  );
                                  return;
                                }
                                // Show loading indicator logic could be added here
                                await calcController.addSubjectFromTemplate(subject, semester);
                                await calcController.recalculateAll();
                                if (context.mounted) Navigator.of(ctx).pop();
                              },
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _showAddSubjectDialog(context, semester);
                      },
                      icon: Icon(Icons.add, size: 18, color: palette.primary),
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

  void _showDeptBasedSubjectPicker(BuildContext context, int semester) {
    final regs = ['2021', '2025'];
    final depts = [
      {'code': 'CB', 'label': 'CSBS'},
      {'code': 'CS', 'label': 'CSE'},
      {'code': 'AD', 'label': 'AIDS'},
    ];

    final selectedReg = RxnString();
    final selectedDeptCode = RxnString();
    final selectedCodes = <String>[].obs;
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
          initialChildSize: 0.85,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Choose by Department",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Dropdowns (wrapped in Obx individually if they depended on other vars, but here they are local)
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Regulation",
                      labelStyle: TextStyle(fontSize: 13),
                      filled: true,
                      fillColor: palette.accent,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: regs.map((r) => DropdownMenuItem(value: r, child: Text("Reg $r"))).toList(),
                    onChanged: (val) {
                      selectedReg.value = val;
                      selectedCodes.clear();
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Department",
                      labelStyle: TextStyle(fontSize: 13),
                      filled: true,
                      fillColor: palette.accent,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: depts.map((d) => DropdownMenuItem(value: d['code'] as String, child: Text(d['label']!))).toList(),
                    onChanged: (val) {
                      selectedDeptCode.value = val;
                      selectedCodes.clear();
                    },
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: Obx(() {
                      final reg = selectedReg.value;
                      final deptCode = selectedDeptCode.value;
                      // Just listening for changes
                      // ignore: unused_local_variable
                      final codesTrigger = selectedCodes.length; 

                      if (reg == null || deptCode == null) {
                        return Center(
                          child: Text(
                            "Select regulation and department to view subjects",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: palette.black),
                          ),
                        );
                      }

                      // OPTIMIZATION: This filtering can be heavy.
                      // Ideally, templates map should be indexed. 
                      // Since we can't change controller, we compute here but only when dropdowns change.
                      final templates = calcController.templates;
                      final filtered = templates.where((s) {
                        return calcController.subjectMatchesMeta(
                          s,
                          regulation: reg,
                          department: deptCode,
                          semester: semester,
                        );
                      }).toList()..sort((a, b) => a.code.compareTo(b.code));

                      if (filtered.isEmpty) {
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
                        itemCount: filtered.length,
                        itemBuilder: (_, index) {
                          final subject = filtered[index];
                          final code = subject.code;
                          
                          // Use Obx only if checking logic is complex, 
                          // but here we are inside a parent Obx, so it's fine.
                          final isSelected = selectedCodes.contains(code);

                          return Card(
                            color: palette.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CheckboxListTile(
                              value: isSelected,
                              onChanged: (val) {
                                if (val == true) {
                                  if (!selectedCodes.contains(code)) selectedCodes.add(code);
                                } else {
                                  selectedCodes.remove(code);
                                }
                              },
                              title: Text(
                                "${subject.code} - ${subject.name}",
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                "${subject.credits.toStringAsFixed(1)} credits",
                                style: const TextStyle(fontSize: 12),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final hasSelection = selectedCodes.isNotEmpty;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasSelection ? palette.primary : palette.black.withAlpha(150),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                        ),
                        onPressed: hasSelection
                            ? () async {
                                final reg = selectedReg.value;
                                final deptCode = selectedDeptCode.value;
                                if (reg == null || deptCode == null) return;

                                // Show a loader dialog here if adding takes time
                                showDialog(
                                  context: context, 
                                  barrierDismissible: false,
                                  builder: (_) => const Center(child: CircularProgressIndicator())
                                );

                                final templates = calcController.templates;
                                final toAdd = templates.where((s) {
                                  if (!selectedCodes.contains(s.code)) return false;
                                  return calcController.subjectMatchesMeta(
                                    s,
                                    regulation: reg,
                                    department: deptCode,
                                    semester: semester,
                                  );
                                }).toList();

                                for (final t in toAdd) {
                                  await calcController.addSubjectFromTemplate(t, semester);
                                }
                                await calcController.recalculateAll();
                                
                                if(context.mounted) {
                                  Navigator.of(context).pop(); // pop loader
                                  Navigator.of(ctx).pop(); // pop sheet
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Added ${toAdd.length} subject(s)")),
                                  );
                                }
                              }
                            : null,
                        child: Text(
                          hasSelection ? "Add selected subjects" : "Select subjects to add",
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

  // Helper dialogs for "Add Subject Options" and "Add Subject Manually" 
  // and "Add Internal" remain largely the same, just keeping them concise.
  void _showAddSubjectOptions(BuildContext context, int semester) {
    final palette = themeController.palette;
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("Add subject to semester", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.list_alt_outlined),
                title: const Text("Choose from subject list"),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showSubjectPickerBottomSheet(context, semester);
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_tree_outlined),
                title: const Text("Choose using department"),
                subtitle: const Text("Regulation • Department • Multi-select", style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showDeptBasedSubjectPicker(context, semester);
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

  void _showAddSubjectDialog(BuildContext context, int semester) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final creditsCtrl = TextEditingController();
    final palette = themeController.palette;

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: palette.bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Add Subject", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildDialogTextField(codeCtrl, "Subject Code", Icons.qr_code_2, palette),
                  const SizedBox(height: 10),
                  _buildDialogTextField(nameCtrl, "Subject Name", Icons.menu_book_outlined, palette),
                  const SizedBox(height: 10),
                  _buildDialogTextField(creditsCtrl, "Credits", Icons.numbers, palette, isNumber: true),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text("Cancel", style: TextStyle(color: palette.primary)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: palette.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final name = nameCtrl.text.trim();
                          final code = codeCtrl.text.trim();
                          final creditsStr = creditsCtrl.text.trim();
                          if (name.isEmpty || code.isEmpty || creditsStr.isEmpty) return;
                          
                          final credits = double.tryParse(creditsStr) ?? 0;
                          if (credits <= 0) return;

                          await calcController.addSubject(
                            name: name, code: code, credits: credits, semester: semester, grade: "O"
                          );
                          if(context.mounted) Navigator.of(ctx).pop();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Text("Save", style: TextStyle(color: palette.accent)),
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

  Widget _buildDialogTextField(TextEditingController ctrl, String label, IconData icon, dynamic palette, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: palette.accent,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  void _showAddInternalDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Internal"),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: "Internal 1")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await internalCtrl.addInternal(selectedSemester, ctrl.text.trim().isEmpty ? "Internal" : ctrl.text.trim());
              if(context.mounted) Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

// ------------------- ISOLATED LIST COMPONENT -------------------

/// OPTIMIZATION: Separated the list into its own widget.
/// This ensures the expensive sorting/filtering happens only when necessary,
/// and is scoped within this part of the widget tree.
class _SubjectListSection extends StatelessWidget {
  final int semester;
  final int internalNo;
  final dynamic palette;

  const _SubjectListSection({
    required this.semester,
    required this.internalNo,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final CgpaCalcController cgpaCtrl = Get.find<CgpaCalcController>();

    return Obx(() {
      // OPTIMIZATION: filtering happens here, inside a scoped Obx
      final subjects = cgpaCtrl.subjects
          .where((s) => s.semester == semester)
          .toList();
      
      // Sort in place to avoid creating another list copy if possible, 
      // or just chain it.
      subjects.sort((a, b) => a.code.compareTo(b.code));

      if (subjects.isEmpty) {
        return Center(
          child: Text(
            "No subjects added for this semester",
            style: TextStyle(fontSize: 13, color: palette.black),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
          // OPTIMIZATION: Use itemExtent or prototypeItem if tiles are fixed height 
          // to drastically improve scroll performance for large lists.
          // prototypeItem: _InternalSubjectTile(subject: subjects[0], semester: semester, internalNo: internalNo),
          itemCount: subjects.length,
          itemBuilder: (_, index) {
            return _InternalSubjectTile(
              subject: subjects[index],
              semester: semester,
              internalNo: internalNo,
              key: ValueKey(subjects[index].code), // Add Key for performance
            );
          },
        ),
      );
    });
  }
}

class _InternalSubjectTile extends StatelessWidget {
  final SubjectModel subject;
  final int semester;
  final int internalNo;

  _InternalSubjectTile({
    super.key, // Added Key
    required this.subject,
    required this.semester,
    required this.internalNo,
  });

  final InternalCalcController ctrl = Get.find<InternalCalcController>();
  final CgpaCalcController cgpaCtrl = Get.find<CgpaCalcController>();
  final ThemeController themeController = Get.find<ThemeController>();
  

  void _confirmDelete(BuildContext context) {
    final palette = themeController.palette;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Subject"),
        content: const Text(
          "This will remove the subject from:\n"
          "• Internal marks\n"
          "• GPA calculation\n"
          "• CGPA calculation\n\n"
          "Are you sure?",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: palette.error),
            onPressed: () async {
              Navigator.pop(context);
              await cgpaCtrl.removeSubjectAndCleanup(subject);
              if(context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Subject deleted successfully")));
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Optimization: Don't fetch palette inside build repeatedly if passed, 
    // but fetching from Get.find is cheap enough.
    final palette = themeController.palette;

    // We keep this bit of logic inside build because it depends on specific item state
    // but we avoid wrapping the whole tile in Obx. 
    // We only wrap the Marks part if we want live updates from other sources, 
    // but usually user input drives this, so standard TextField is fine.
    
    // Check for existing marks
    // OPTIMIZATION: marksList searching can be slow if list is huge. 
    // Ideally, pass a Map or specific Mark object. 
    // Assuming list isn't massive (internals usually < 100 entries).
    final existing = ctrl.markList.firstWhereOrNull(
      (m) => m.semester == semester && m.internalNo == internalNo && m.subjectCode == subject.code,
    );

    final TextEditingController markCtrl = TextEditingController(
      text: existing?.marks.toStringAsFixed(0) ?? '',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: palette.accent,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            offset: const Offset(0, 2),
            color: palette.black.withAlpha(20),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.code.isNotEmpty ? "${subject.code} - ${subject.name}" : subject.name,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  "${subject.credits.toStringAsFixed(1)} credits",
                  style: TextStyle(fontSize: 11, color: palette.black.withAlpha(150)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: TextField(
              controller: markCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "Marks",
                filled: true,
                fillColor: palette.bg.withAlpha(150),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onSubmitted: (val) {
                final obtained = double.tryParse(val) ?? 0;
                ctrl.addOrUpdateMark(
                  semester: semester,
                  internalNo: internalNo,
                  subject: subject,
                  obtainedMarks: obtained,
                  maxMarks: 100,
                );
                // No focus unfocus here to allow quick entry of next subject
                // FocusScope.of(context).unfocus(); 
              },
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: "Delete subject",
            icon: Icon(Icons.delete_outline, color: palette.error, size: 22),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }
}