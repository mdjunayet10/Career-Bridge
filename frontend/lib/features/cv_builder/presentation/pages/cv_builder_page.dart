import 'dart:math' as math;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../../../../core/services/cv_import_service.dart';
import '../../../auth/controllers/auth_controller.dart';

import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/services/cv_pdf_service.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../../job_seeker/controllers/job_seeker_workspace_controller.dart';
import '../../../job_seeker/presentation/widgets/job_seeker_navigation.dart';
import '../../../job_seeker/presentation/widgets/job_seeker_workspace_gate.dart';
import '../../data/models/cv_profile_model.dart';
import '../widgets/cv_document_preview.dart';

class CvBuilderPage extends StatelessWidget {
  const CvBuilderPage({super.key});

  @override
  Widget build(BuildContext context) => DashboardShell(
        role: UserRole.jobSeeker,
        title: 'CV Builder',
        subtitle:
            'Your CV is built from your Profile. Choose its layout, preview it, and download the PDF.',
        items: JobSeekerNavigation.items,
        selectedIndex: 5,
        constrainBodyToViewport: true,
        body: JobSeekerWorkspaceGate(
          builder: (context, controller) => _CvWorkspace(
            controller: controller,
            cv: controller.cvProfile!,
          ),
        ),
      );
}

class _CvWorkspace extends StatefulWidget {
  const _CvWorkspace({required this.controller, required this.cv});

  final JobSeekerWorkspaceController controller;
  final CvProfileModel cv;

  @override
  State<_CvWorkspace> createState() => _CvWorkspaceState();
}

class _CvWorkspaceState extends State<_CvWorkspace> {
  late List<CvSection> _order;
  late Set<String> _hidden;
  late bool _showPhoto;
  late String _templateId;
  bool _dirty = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _readLayout();
  }

  @override
  void didUpdateWidget(_CvWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dirty) _readLayout();
  }

  Future<void> _importCv() async {
    try {
      final files = await FilePicker.platform.pickFiles(
          type: FileType.custom, allowedExtensions: ['json'], withData: true);
      if (files == null || !mounted) return;
      final bytes = files.files.single.bytes;
      if (bytes == null) {
        throw const FormatException('Could not read the selected file.');
      }
      final user = AuthController.instance.currentUser;
      if (user == null) return;
      final cv = CvImportService.parse(utf8.decode(bytes),
          current: widget.controller.cvProfile!,
          authenticatedEmail: user.email);
      final approved = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Import profile and CV?'),
                content: SingleChildScrollView(
                    child: Text(
                        '${cv.fullName}\n${cv.email}\n${cv.phone}\n${cv.location}\n\n${cv.education.length} education entries, ${cv.projects.length} projects, ${cv.achievements.length} achievements.\n\nSelected fields will replace your saved profile and CV. Fields omitted from the file are kept. You can edit the result in Profile.')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Import and save'))
                ],
              ));
      if (approved != true ||
          !mounted ||
          AuthController.instance.currentUser?.uid != user.uid) {
        return;
      }
      await widget.controller.saveCvProfile(cv, syncSummaryToProfile: true);
      if (mounted) {
        setState(() {
          _dirty = false;
          _readLayout();
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error is FormatException
                ? error.message
                : 'Could not import the CV. Check your connection and try again.')));
      }
    }
  }

  void _readLayout() {
    _order = List.of(widget.cv.orderedSections);
    _hidden = widget.cv.hiddenSections.toSet();
    _showPhoto = widget.cv.showPhoto;
    _templateId = widget.cv.templateId;
  }

  CvProfileModel get _previewCv => widget.cv.copyWith(
        sectionOrder: _order.map((section) => section.name).toList(),
        hiddenSections: _hidden.toList(),
        showPhoto: _showPhoto,
        templateId: _templateId,
      );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 960;
          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                  onPressed: widget.controller.isSaving ? null : _importCv,
                  icon: const Icon(Icons.file_upload_outlined),
                  label: const Text('Import CV data')),
              OutlinedButton.icon(
                onPressed: widget.controller.isSaving ? null : _editProfile,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Profile'),
              ),
              OutlinedButton.icon(
                onPressed: _showLayout,
                icon: const Icon(Icons.tune_rounded),
                label: const Text('CV layout'),
              ),
              FilledButton.icon(
                onPressed: _isExporting ? null : _exportPdf,
                icon: _isExporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Generate PDF'),
              ),
            ],
          );
          final preview = LayoutBuilder(
            builder: (context, previewConstraints) => CvDocumentPreview(
              cv: _previewCv,
              height: wide
                  ? previewConstraints.maxHeight
                  : math.min(1100, constraints.maxWidth * 1.4143 + 64),
            ),
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Information and photo sync from your saved Profile. One page is recommended; longer CVs are supported.',
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 12, height: 1.5),
              ),
              const SizedBox(height: 14),
              actions,
              const SizedBox(height: 18),
              // Small screens show the paper across the full content width. There
              // is no competing details column or second information form.
              if (wide) Expanded(child: preview) else preview,
            ],
          );
        },
      );

  Future<void> _showLayout() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * .8),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            child: StatefulBuilder(
              builder: (context, updateSheet) => ListenableBuilder(
                listenable: widget.controller,
                builder: (context, _) => _layoutOptions(
                  refresh: () {
                    if (context.mounted) updateSheet(() {});
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _changeLayout(VoidCallback change, VoidCallback refresh) {
    setState(change);
    refresh();
  }

  Widget _layoutOptions({required VoidCallback refresh}) {
    final options = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
            'Show or hide sections and change their order. Hidden sections stay saved in Profile.',
            style: TextStyle(
                color: AppColors.textMuted, fontSize: 12, height: 1.5)),
        const SizedBox(height: 12),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show photo'),
          value: _showPhoto,
          onChanged: widget.controller.isSaving
              ? null
              : (value) => _changeLayout(() {
                    _showPhoto = value;
                    _dirty = true;
                  }, refresh),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Compact spacing'),
          subtitle: const Text('Fit more content while keeping readable text.'),
          value: _templateId == 'reference-compact',
          onChanged: widget.controller.isSaving
              ? null
              : (value) => _changeLayout(() {
                    _templateId =
                        value ? 'reference-compact' : 'reference-classic';
                    _dirty = true;
                  }, refresh),
        ),
        for (var i = 0; i < _order.length; i++) _sectionRow(i, refresh),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: !_dirty || widget.controller.isSaving
              ? null
              : () async {
                  await _saveLayout();
                  refresh();
                },
          icon: const Icon(Icons.save_outlined),
          label: Text(widget.controller.isSaving ? 'Saving…' : 'Save layout'),
        ),
        if (_dirty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Unsaved layout changes',
                style: TextStyle(color: AppColors.textSubtle, fontSize: 11)),
          ),
      ],
    );
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              const Expanded(
                  child: Text('CV layout',
                      style: TextStyle(fontWeight: FontWeight.w800))),
              IconButton(
                  tooltip: 'Close layout',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)),
            ]),
            const SizedBox(height: 12),
            options,
          ],
        ),
      ),
    );
  }

  Widget _sectionRow(int index, VoidCallback refresh) {
    final section = _order[index];
    return Row(
      key: ValueKey('cv-section-${section.name}'),
      children: [
        Expanded(
            child: CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(section.label, style: const TextStyle(fontSize: 12)),
          value: !_hidden.contains(section.name),
          onChanged: widget.controller.isSaving
              ? null
              : (visible) => _changeLayout(() {
                    visible == true
                        ? _hidden.remove(section.name)
                        : _hidden.add(section.name);
                    _dirty = true;
                  }, refresh),
        )),
        IconButton(
          tooltip: 'Move ${section.label} up',
          onPressed: widget.controller.isSaving || index == 0
              ? null
              : () => _move(index, index - 1, refresh),
          icon: const Icon(Icons.arrow_upward_rounded, size: 18),
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          tooltip: 'Move ${section.label} down',
          onPressed: widget.controller.isSaving || index == _order.length - 1
              ? null
              : () => _move(index, index + 1, refresh),
          icon: const Icon(Icons.arrow_downward_rounded, size: 18),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  void _move(int from, int to, VoidCallback refresh) => _changeLayout(() {
        final section = _order.removeAt(from);
        _order.insert(to, section);
        _dirty = true;
      }, refresh);

  Future<bool> _saveLayout() async {
    try {
      await widget.controller.saveCvPresentation(
        sectionOrder: _order.map((section) => section.name).toList(),
        hiddenSections: _hidden.toList(),
        showPhoto: _showPhoto,
        templateId: _templateId,
      );
      if (mounted) setState(() => _dirty = false);
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              widget.controller.errorMessage ?? 'Could not save CV layout.'),
        ));
      }
      return false;
    }
  }

  Future<void> _editProfile() async {
    if (_dirty && !await _saveLayout()) return;
    if (mounted) await Navigator.pushNamed(context, AppRoutes.jobSeekerProfile);
  }

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);
    try {
      await CvPdfService.instance.shareOrDownload(_previewCv);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CV PDF generated on this device.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}
