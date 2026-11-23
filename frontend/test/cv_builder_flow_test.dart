import 'dart:typed_data';

import 'package:career_bridge/app/router/app_routes.dart';
import 'package:career_bridge/core/services/cv_pdf_service.dart';
import 'package:career_bridge/features/auth/controllers/auth_controller.dart';
import 'package:career_bridge/features/cv_builder/data/models/cv_profile_model.dart';
import 'package:career_bridge/features/cv_builder/presentation/pages/cv_builder_page.dart';
import 'package:career_bridge/features/cv_builder/presentation/widgets/cv_details_editor.dart';
import 'package:career_bridge/features/cv_builder/presentation/widgets/cv_live_preview.dart';
import 'package:career_bridge/features/cv_builder/presentation/widgets/cv_document_preview.dart';
import 'package:career_bridge/features/job_seeker/controllers/job_seeker_workspace_controller.dart';
import 'package:career_bridge/features/job_seeker/presentation/pages/job_seeker_profile_page.dart';
import 'package:career_bridge/features/public_portal/controllers/public_portal_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:printing/printing.dart';
import 'package:printing/src/interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    FilePicker.platform = _PhotoPicker();
    // Load real font assets before the per-test FakeAsync clocks start.
    // This also verifies that the bundled Latin Modern assets produce a PDF.
    final bytes = await CvPdfService.instance.buildPdf(_sampleCv());
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  testWidgets('typing shared CV details keeps focus and cursor across rebuilds',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_EditorHarness(profile: _sampleCv()));

    for (final label in [
      'Degree / qualification',
      'Languages',
      'Role / position',
      'Experience description',
    ]) {
      final field = _field(label).first;
      await tester.ensureVisible(field);
      await tester.tap(field);
      await tester.pump();
      final editable =
          find.descendant(of: field, matching: find.byType(EditableText));
      final state = tester.state<EditableTextState>(editable);

      final values = label == 'Experience description'
          ? ['P', 'Prepared reports.', 'Prepared reports.\nReviewed accounts.']
          : ['E', 'Ex', 'Excel, R'];
      for (final value in values) {
        tester.testTextInput.updateEditingValue(TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        ));
        await tester.pump();
        final widget = tester.widget<EditableText>(editable);
        expect(tester.state<EditableTextState>(editable), same(state));
        expect(widget.focusNode.hasFocus, isTrue);
        expect(widget.controller.text, value);
        expect(widget.controller.selection.baseOffset, value.length);
      }
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('removing first detail rows keeps edited surviving rows',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final key = GlobalKey<_EditorHarnessState>();
    await tester.pumpWidget(_EditorHarness(key: key, profile: _sampleCv()));

    expect(tester.getRect(find.text('Projects')).top,
        lessThan(tester.getRect(find.text('Experience')).top));
    expect(
        tester.getRect(find.text('Experience')).top,
        lessThan(
            tester.getRect(find.text('Achievements & Certifications')).top));
    await _tap(tester, find.widgetWithText(OutlinedButton, 'Add experience'));
    expect(_field('Role / position'), findsNWidgets(3));
    final temporaryRole = _field('Role / position').last;
    await tester.ensureVisible(temporaryRole);
    await tester.enterText(temporaryRole, 'Temporary role');
    await tester.pump();
    await _tap(tester, find.byTooltip('Remove Experience 3'));
    expect(_field('Role / position'), findsNWidgets(2));

    for (final entry in [
      ('Degree / qualification', 'Remove Education 1', 'MBA'),
      ('Project name', 'Remove Project 1', 'Financial literacy project'),
      ('Role / position', 'Remove Experience 1', 'Finance Officer'),
      (
        'Award or certificate title',
        'Remove Achievement / certification 1',
        'Accounting certification'
      ),
      ('Name', 'Remove Reference 1', 'Dr. Mina Rahman'),
    ]) {
      final survivor = _field(entry.$1).at(1);
      await tester.ensureVisible(survivor);
      await tester.enterText(survivor, entry.$3);
      await tester.pump();
      final deleteFirst = find.byTooltip(entry.$2);
      await tester.ensureVisible(deleteFirst);
      await tester.tap(deleteFirst);
      await tester.pump();
      expect(_field(entry.$1), findsOneWidget);
      expect(_fieldText(tester, entry.$1), entry.$3);
    }

    expect(key.currentState!.profile.education.single.degree, 'MBA');
    expect(key.currentState!.profile.projects.single.name,
        'Financial literacy project');
    expect(key.currentState!.profile.experience.single.role, 'Finance Officer');
    expect(_fieldText(tester, 'Organization'), 'Second organization');
    expect(_fieldText(tester, 'Experience dates / period'), '2025');
    expect(_fieldText(tester, 'Experience description'),
        'Analyzed costs.\nSupported planning.');
    expect(key.currentState!.profile.achievements.single.title,
        'Accounting certification');
    expect(key.currentState!.profile.references.single.name, 'Dr. Mina Rahman');
    expect(tester.takeException(), isNull);
  });

  for (final width in [1440.0, 390.0]) {
    testWidgets(
        'Profile supplies CV; layout and preview work at ${width.toInt()}px',
        (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final originalPrinting = PrintingPlatform.instance;
      final printing = _PreviewPrinting();
      PrintingPlatform.instance = printing;
      addTearDown(() => PrintingPlatform.instance = originalPrinting);
      final originalPicker = FilePicker.platform;
      final picker = _PhotoPicker()..bytes = _photoBytes(255, 0, 0);
      FilePicker.platform = picker;
      addTearDown(() => FilePicker.platform = originalPicker);
      final controller = JobSeekerWorkspaceController.instance;
      await tester.runAsync(() async {
        await AuthController.instance.resetForTesting();
        controller.resetForTesting();
        PublicPortalController.instance.resetForTesting();
        await AuthController.instance
            .signIn(email: 'jobseeker@careerbridge.demo', password: 'Demo123!');
        await controller.ensureLoaded();
        await controller.saveProfile(controller.profile!.copyWith(
          hasCvDetails: true,
          projects: const [
            CvProjectItem(
                name: 'Community budget study',
                description: 'Analyzed local budgets.')
          ],
        ));
        await controller.uploadProfileImage();
      });
      final source = controller.profile!.toFirestore();
      final photo = controller.cvProfile!.photoDataUrl;
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(splashFactory: NoSplash.splashFactory),
        home: const CvBuilderPage(),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsNothing);
      expect(find.byType(CvDetailsEditor), findsNothing);
      expect(
          tester
              .widget<CvLivePreview>(find.byType(CvLivePreview))
              .cv
              .photoDataUrl,
          photo);
      final liveWidth = tester
          .getSize(find.descendant(
              of: find.byType(CvLivePreview), matching: find.byType(Image)))
          .width;
      if (width < 960) {
        expect(liveWidth, closeTo(width - 36, 1));
        expect(find.byType(CheckboxListTile), findsNothing);
      }
      expect(find.byType(CvDocumentPreview), findsOneWidget);
      expect(find.byType(CvLivePreview), findsOneWidget);
      expect(find.text('LIVE CV PREVIEW'), findsNothing);
      expect(find.widgetWithText(OutlinedButton, 'Preview PDF'), findsNothing);
      expect(find.text('CV preview'), findsOneWidget);
      expect(liveWidth, width >= 960 ? 1000 : closeTo(width - 36, 1));
      expect(printing.downloads, isEmpty);
      expect(printing.printCalls, 0);
      await _tap(tester, find.byTooltip('Zoom in'));
      await tester.pumpAndSettle();
      expect(find.text('125%'), findsOneWidget);
      expect(find.byType(CvLivePreview), findsOneWidget);
      expect(printing.downloads, isEmpty);
      await _tap(tester, find.byTooltip('Zoom out'));
      await tester.pumpAndSettle();
      expect(find.text('100%'), findsOneWidget);
      await _tap(tester, find.widgetWithText(OutlinedButton, 'CV layout'));
      await tester.pumpAndSettle();
      final projects = find.widgetWithText(CheckboxListTile, 'Projects');
      await _tap(tester, projects);
      await _tap(tester, find.byTooltip('Move Experience up'));
      await _tap(tester, find.widgetWithText(SwitchListTile, 'Show photo'));
      await _tap(tester, find.widgetWithText(OutlinedButton, 'Save layout'));
      await tester.pumpAndSettle();
      await _tap(tester, find.byTooltip('Close layout'));
      await tester.pumpAndSettle();
      await tester.runAsync(controller.refresh);
      await tester.pumpAndSettle();
      expect(controller.cvProfile!.hiddenSections, ['projects']);
      expect(
          controller.cvProfile!.orderedSections.indexOf(CvSection.experience),
          lessThan(controller.cvProfile!.orderedSections
              .indexOf(CvSection.projects)));
      expect(controller.cvProfile!.showPhoto, isFalse);
      expect(controller.cvProfile!.photoDataUrl, photo);
      expect(controller.profile!.toFirestore(), source);
      expect(controller.profile!.projects, isNotEmpty);
      // Updating Profile changes preview data while retaining CV layout choices.
      await tester.runAsync(() => controller.saveProfile(
          controller.profile!.copyWith(fullName: 'Updated profile name')));
      await tester.pumpAndSettle();
      final preview =
          tester.widget<CvLivePreview>(find.byType(CvLivePreview)).cv;
      expect(preview.fullName, 'Updated profile name');
      expect(preview.hiddenSections, ['projects']);
      expect(preview.showPhoto, isFalse);
      await _tap(tester, find.widgetWithText(FilledButton, 'Generate PDF'));
      await tester.pumpAndSettle();
      expect(printing.downloads, hasLength(1));
      expect(String.fromCharCodes(printing.downloads.single.take(5)), '%PDF-');
      expect(printing.printCalls, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'non-CSE profile CV edits and clears survive reload at ${width.toInt()}px',
        (tester) async {
      await tester.binding
          .setSurfaceSize(Size(width, width < 400 ? 844 : 1100));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final originalPrinting = PrintingPlatform.instance;
      PrintingPlatform.instance = _PreviewPrinting();
      addTearDown(() => PrintingPlatform.instance = originalPrinting);
      final controller = JobSeekerWorkspaceController.instance;
      await tester.runAsync(() async {
        await AuthController.instance.resetForTesting();
        controller.resetForTesting();
        PublicPortalController.instance.resetForTesting();
        await AuthController.instance
            .signIn(email: 'jobseeker@careerbridge.demo', password: 'Demo123!');
        await controller.ensureLoaded();
        await controller.saveProfile(controller.profile!.copyWith(
          hasCvDetails: true,
          education: const [],
          technicalLanguages: const [],
          frameworks: const [],
          toolsAndPlatforms: const [],
          projects: const [],
          experience: const [],
          achievements: const [],
          references: const [],
          skills: const [],
        ));
      });

      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(splashFactory: NoSplash.splashFactory),
        navigatorKey: navigatorKey,
        initialRoute: AppRoutes.jobSeekerProfile,
        routes: {
          AppRoutes.jobSeekerProfile: (_) => const JobSeekerProfilePage(),
          AppRoutes.jobSeekerCvBuilder: (_) => const CvBuilderPage(),
        },
      ));
      await tester.pumpAndSettle();

      await _enter(tester, 'Full name', 'Ayesha Rahman');
      await _enter(tester, 'Professional headline', 'Finance Graduate');
      await _enter(tester, 'Contact email', 'ayesha@example.com');
      await _enter(tester, 'Professional summary',
          'Finance graduate with experience in budgeting and research.');
      await _tap(tester, find.widgetWithText(OutlinedButton, 'Add education'));
      await _enter(tester, 'Degree / qualification', 'BBA in Finance');
      await _enter(tester, 'Institution', 'Independent University');
      await _enter(tester, 'Dates / period', '2022 - 2026');
      await _enter(tester, 'Tools and Platforms', 'Excel, SPSS');
      await _tap(tester, find.widgetWithText(OutlinedButton, 'Add project'));
      await _enter(tester, 'Project name', 'Community budget study');
      await _enter(tester, 'Project description',
          'Analyzed household budgets.\nPresented financial recommendations.');
      await _tap(tester, find.widgetWithText(OutlinedButton, 'Add experience'));
      await _enter(tester, 'Role / position', 'Finance Intern');
      await _enter(tester, 'Organization', 'Community Finance Foundation');
      await _enter(tester, 'Experience dates / period', 'Jun 2026 - Sep 2026');
      await _enter(tester, 'Experience description',
          'Prepared monthly budget reports.\nSupported financial research.');
      await _tap(
          tester,
          find.widgetWithText(
              OutlinedButton, 'Add achievement or certification'));
      await _enter(tester, 'Award or certificate title',
          'Financial Reporting Certificate');
      await _enter(tester, 'Achievement description (optional)',
          'Completed reporting training.\nEarned distinction.');
      for (final label in [
        'Project description',
        'Experience description',
        'Achievement description (optional)',
      ]) {
        expect(tester.widget<TextField>(_field(label)).decoration?.helperText,
            'One bullet point per line.');
      }
      await _tap(tester, find.widgetWithText(FilledButton, 'Save profile'));
      await tester.pumpAndSettle();

      expect(controller.cvProfile!.fullName, 'Ayesha Rahman');
      expect(controller.cvProfile!.education.single.degree, 'BBA in Finance');
      expect(controller.cvProfile!.toolsAndPlatforms, ['Excel', 'SPSS']);
      expect(controller.cvProfile!.frameworks, isEmpty);
      expect(
          controller.cvProfile!.projects.single.name, 'Community budget study');
      expect(controller.cvProfile!.experience.single.role, 'Finance Intern');
      expect(controller.cvProfile!.experience.single.description,
          'Prepared monthly budget reports.\nSupported financial research.');
      expect(controller.cvProfile!.projects.single.description,
          'Analyzed household budgets.\nPresented financial recommendations.');
      expect(controller.cvProfile!.achievements.single.description,
          'Completed reporting training.\nEarned distinction.');

      navigatorKey.currentState!
          .pushReplacementNamed(AppRoutes.jobSeekerCvBuilder);
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsNothing);
      final preview =
          tester.widget<CvLivePreview>(find.byType(CvLivePreview)).cv;
      expect(preview.fullName, 'Ayesha Rahman');
      expect(preview.education.single.degree, 'BBA in Finance');
      expect(preview.toolsAndPlatforms, ['Excel', 'SPSS']);
      expect(preview.experience.single.role, 'Finance Intern');
      expect(find.textContaining('Co-curricular'), findsNothing);
      expect(find.text('BCSE 23'), findsNothing);
      expect(find.text('Ongoing'), findsNothing);
      await _tap(tester, find.widgetWithText(OutlinedButton, 'Edit Profile'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(_fieldText(tester, 'Full name'), 'Ayesha Rahman');
      expect(_fieldText(tester, 'Project name'), 'Community budget study');

      await _enter(tester, 'Tools and Platforms', 'Excel, SPSS, Power BI');
      await _enter(tester, 'Project name', 'Community budget analysis');
      await _enter(tester, 'Role / position', 'Finance Analyst');
      await _enter(tester, 'Experience description',
          'Prepared monthly budget reports.\nAnalyzed financial research data.');
      await _enter(tester, 'Achievement description (optional)',
          'Completed advanced reporting training.\nEarned distinction.');
      await _tap(tester, find.widgetWithText(FilledButton, 'Save profile'));
      await tester.pumpAndSettle();
      await tester.runAsync(controller.refresh);
      await tester.pumpAndSettle();
      expect(
          controller.profile!.toolsAndPlatforms, ['Excel', 'SPSS', 'Power BI']);
      expect(controller.profile!.projects.single.name,
          'Community budget analysis');
      expect(controller.profile!.experience.single.role, 'Finance Analyst');
      expect(controller.profile!.experience.single.description,
          'Prepared monthly budget reports.\nAnalyzed financial research data.');
      expect(controller.profile!.achievements.single.description,
          'Completed advanced reporting training.\nEarned distinction.');
      expect(_fieldText(tester, 'Project name'), 'Community budget analysis');

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await _enter(tester, 'Tools and Platforms', '');
      await _tap(tester, find.byTooltip('Remove Project 1'));
      await _tap(tester, find.byTooltip('Remove Experience 1'));
      await _tap(
          tester, find.byTooltip('Remove Achievement / certification 1'));
      await _tap(tester, find.widgetWithText(FilledButton, 'Save profile'));
      await tester.pumpAndSettle();
      await tester.runAsync(controller.refresh);
      await tester.pumpAndSettle();
      expect(controller.cvProfile!.toolsAndPlatforms, isEmpty);
      expect(controller.cvProfile!.projects, isEmpty);
      expect(controller.cvProfile!.experience, isEmpty);
      expect(controller.cvProfile!.achievements, isEmpty);
      expect(controller.profile!.toolsAndPlatforms, isEmpty);
      expect(controller.profile!.projects, isEmpty);
      expect(controller.profile!.experience, isEmpty);
      expect(controller.profile!.achievements, isEmpty);
      expect(controller.profile!.hasCvExperience, isTrue);
      expect(controller.profile!.hasCvDetails, isTrue);

      navigatorKey.currentState!
          .pushReplacementNamed(AppRoutes.jobSeekerProfile);
      await tester.pumpAndSettle();
      expect(_fieldText(tester, 'Tools and Platforms'), isEmpty);
      expect(_field('Project name'), findsNothing);
      expect(_field('Role / position'), findsNothing);
      expect(_field('Award or certificate title'), findsNothing);
      expect(_fieldText(tester, 'Degree / qualification'), 'BBA in Finance');
      expect(tester.takeException(), isNull);
    });
  }
}

Finder _field(String label) => find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == label);

String _fieldText(WidgetTester tester, String label) {
  final editable =
      find.descendant(of: _field(label), matching: find.byType(EditableText));
  return tester.widget<EditableText>(editable).controller.text;
}

Future<void> _enter(WidgetTester tester, String label, String value) async {
  final field = _field(label);
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

CvProfileModel _sampleCv() => CvProfileModel(
      ownerUid: 'editor-test',
      fullName: 'Ayesha Rahman',
      email: 'ayesha@example.com',
      education: const [
        CvEducationItem(
            degree: 'BBA', institution: 'University', period: '2026'),
        CvEducationItem(degree: 'HSC', institution: 'College', period: '2022'),
      ],
      projects: const [
        CvProjectItem(name: 'First project', description: 'Budget study'),
        CvProjectItem(name: 'Second project', description: 'Financial report'),
      ],
      experience: const [
        CvExperienceItem(
          role: 'First role',
          company: 'First organization',
          period: '2024',
          description: 'Prepared reports.\nReviewed accounts.',
        ),
        CvExperienceItem(
          role: 'Second role',
          company: 'Second organization',
          period: '2025',
          description: 'Analyzed costs.\nSupported planning.',
        ),
      ],
      achievements: const [
        CvAchievementItem(title: 'First award'),
        CvAchievementItem(title: 'Second award'),
      ],
      references: const [
        CvReferenceItem(name: 'First referee'),
        CvReferenceItem(name: 'Second referee'),
      ],
      updatedAt: DateTime(2026, 10, 11),
    );

class _EditorHarness extends StatefulWidget {
  const _EditorHarness({required this.profile, super.key});

  final CvProfileModel profile;

  @override
  State<_EditorHarness> createState() => _EditorHarnessState();
}

class _EditorHarnessState extends State<_EditorHarness> {
  late CvProfileModel profile = widget.profile;

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(splashFactory: NoSplash.splashFactory),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              child: CvDetailsEditor(
                profile: profile,
                onChanged: (value) => setState(() => profile = value),
              ),
            ),
          ),
        ),
      );
}

// This test validates the editor flow. Browser QA verifies the real PDF raster.
class _PreviewPrinting extends PrintingPlatform {
  final downloads = <Uint8List>[];
  int printCalls = 0;

  @override
  Future<PrintingInfo> info() async => const PrintingInfo(canRaster: true);

  @override
  Stream<PdfRaster> raster(
      Uint8List document, List<int>? pages, double dpi) async* {
    yield _PreviewRaster();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #layoutPdf) {
      printCalls++;
      return Future<bool>.value(true);
    }
    if (invocation.memberName == #sharePdf) {
      downloads.add(invocation.positionalArguments.first as Uint8List);
      return Future<bool>.value(true);
    }
    return super.noSuchMethod(invocation);
  }
}

Uint8List _photoBytes(int r, int g, int b) => img
    .encodePng(img.Image(width: 32, height: 32)..clear(img.ColorRgb8(r, g, b)));

class _PhotoPicker extends FilePicker {
  Uint8List? bytes;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async =>
      bytes == null
          ? null
          : FilePickerResult([
              PlatformFile(
                  name: 'photo.png', size: bytes!.length, bytes: bytes),
            ]);
}

class _PreviewRaster extends PdfRaster {
  _PreviewRaster() : super(1, 1, Uint8List.fromList([255, 255, 255, 255]));

  static final png = img.encodePng(
      img.Image(width: 1, height: 1)..setPixelRgb(0, 0, 255, 255, 255));

  @override
  Future<Uint8List> toPng() async => png;
}
