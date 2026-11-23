import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../constants/file_limits.dart';
import '../../features/cv_builder/data/models/cv_profile_model.dart';
import '../../features/file_storage/data/models/prepared_file.dart';
import 'file_validation_service.dart';

class CvPdfService {
  CvPdfService._();

  static final CvPdfService instance = CvPdfService._();

  // LaTeX article 10pt optical sizes, converted from TeX points to PDF points.
  static const _nameSize = 17.2154;
  static const _headingSize = 11.9552;
  static const _bodySize = 9.9626;
  static const _contactSize = 8.9664;
  static const _texPoint = 72 / 72.27;
  static const _linkColor = PdfColor(.0784, .3137, .6275);
  static const _mutedColor = PdfColor(.502, .502, .502);
  static _CvFonts? _fonts;

  Future<Uint8List> buildPdf(CvProfileModel cv) async {
    final fonts = _fonts ??= await _loadFonts();
    final compact = cv.templateId == 'reference-compact';
    List<pw.Widget> sectionHeading(String title) =>
        _sectionHeading(title, compact: compact);
    final document = pw.Document(
      title: cv.title,
      author: cv.fullName,
      creator: 'Career Bridge',
      subject: 'Curriculum Vitae',
    );
    final photo = _profilePhoto(cv.photoDataUrl) ?? fonts.placeholder;
    final education = cv.education
        .where((item) => _hasText([
              item.degree,
              item.institution,
              item.period,
              item.location,
              item.result,
              item.details,
              item.institutionUrl,
            ]))
        .toList();
    final projects = cv.projects
        .where((item) => _hasText([
              item.name,
              item.description,
              item.link,
              item.toolsAndMethods,
            ]))
        .toList();
    final experience = cv.experience
        .where((item) => _hasText([
              item.role,
              item.company,
              item.period,
              item.description,
            ]))
        .toList();
    final achievements = cv.achievements
        .where((item) => _hasText([
              item.title,
              item.qualifier,
              item.date,
              item.description,
            ]))
        .toList();
    final references = cv.references
        .where((item) => _hasText([
              item.name,
              item.designation,
              item.organization,
              item.email,
              item.phone,
            ]))
        .toList();
    final skills = _technicalSkills(cv, compact: compact);

    final sections = <CvSection, List<pw.Widget>>{
      CvSection.summary: [
        if (cv.professionalSummary.trim().isNotEmpty) ...[
          ...sectionHeading('Professional Summary'),
          _richText([pw.TextSpan(text: cv.professionalSummary.trim())]),
        ],
      ],
      CvSection.languages: [
        if (_values(cv.languages).isNotEmpty) ...[
          ...sectionHeading('Spoken Languages'),
          _richText([pw.TextSpan(text: _values(cv.languages).join(', '))]),
        ],
      ],
      CvSection.education: [
        if (education.isNotEmpty) ...[
          ...sectionHeading('Education'),
          for (var index = 0; index < education.length; index++) ...[
            pw.NewPage(freeSpace: 25),
            ..._education(education[index],
                bottom: index == education.length - 1 ? 0 : 5 * _texPoint),
          ],
        ],
      ],
      CvSection.skills: [
        if (skills.isNotEmpty) ...[
          ...sectionHeading('Technical Skills'),
          ...skills,
        ],
      ],
      CvSection.projects: [
        if (projects.isNotEmpty) ...[
          ...sectionHeading('Projects'),
          for (var index = 0; index < projects.length; index++) ...[
            ..._projectOrExperience(
              title: projects[index].name,
              link: projects[index].link,
              metadata: projects[index].toolsAndMethods,
              description: projects[index].description,
              bottom: index == projects.length - 1 ? 0 : 4,
            ),
          ],
        ],
      ],
      CvSection.experience: [
        if (experience.isNotEmpty) ...[
          ...sectionHeading('Experience'),
          for (var index = 0; index < experience.length; index++) ...[
            ..._projectOrExperience(
              title: experience[index].role,
              organization: experience[index].company,
              metadata: experience[index].period,
              description: experience[index].description,
              bottom: index == experience.length - 1 ? 0 : 4,
            ),
          ],
        ],
      ],
      CvSection.achievements: [
        if (achievements.isNotEmpty) ...[
          ...sectionHeading('Achievements & Certifications'),
          for (var index = 0; index < achievements.length; index++) ...[
            pw.NewPage(freeSpace: 25),
            _alignedRow([
              _bold(achievements[index].title.trim()),
              if (achievements[index].qualifier.trim().isNotEmpty)
                _bold(' — ${achievements[index].qualifier.trim()}'),
            ], [
              if (!compact || achievements[index].date.trim().isNotEmpty)
                _italic(achievements[index].date.trim())
            ]),
            ..._bullets(achievements[index].description),
            if (index != achievements.length - 1) pw.SizedBox(height: 4),
          ],
        ],
      ],
      CvSection.references: [
        if (references.isNotEmpty) ...[
          ...sectionHeading('References'),
          for (var index = 0; index < references.length; index += 2) ...[
            pw.NewPage(freeSpace: 42),
            pw.Partitions(children: [
              pw.Partition(
                  child: pw.Padding(
                      padding: const pw.EdgeInsets.only(right: 6),
                      child: _reference(references[index]))),
              pw.Partition(
                  child: pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 6),
                      child: index + 1 < references.length
                          ? _reference(references[index + 1])
                          : _richText([]))),
            ]),
            if (index + 2 < references.length) pw.SizedBox(height: 5),
          ],
        ],
      ],
    };

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(50.4, 46.8, 50.4, 46.8),
        maxPages: 1000,
        theme: pw.ThemeData.withFont(
          base: fonts.regular,
          bold: fonts.bold,
          italic: fonts.italic,
          boldItalic: fonts.boldItalic,
        ),
        footer: (context) => pw.Transform.translate(
            offset: const PdfPoint(0, -31.628),
            child: pw.Center(
                child: pw.FittedBox(
              fit: pw.BoxFit.scaleDown,
              child: pw.Text(
                '${cv.fullName.trim().isEmpty ? 'CV' : _printable(cv.fullName.trim())} — '
                'Page ${context.pageNumber} of ${context.pagesCount}',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                    font: fonts.smallItalic,
                    fontSize: _contactSize,
                    color: _mutedColor,
                    fontStyle: pw.FontStyle.italic),
              ),
            ))),
        build: (context) => [
          _header(cv, photo, fonts, compact: compact),
          pw.SizedBox(height: 6),
          for (final section in cv.orderedSections)
            if (cv.isSectionVisible(section)) ...sections[section]!,
        ],
      ),
    );

    final bytes = await document.save();
    if (bytes.lengthInBytes > FileLimits.maxFileBytes) {
      throw const FileValidationException(
        'The generated CV is larger than 2 MB. Reduce the photo size or amount of text before exporting.',
      );
    }
    return bytes;
  }

  Future<_CvFonts> _loadFonts() async {
    Future<pw.Font> load(String name) async =>
        pw.Font.ttf(await rootBundle.load('assets/cv_fonts/$name.ttf'));
    return _CvFonts(
      await load('lmroman10-regular'),
      await load('lmroman10-bold'),
      await load('lmroman10-italic'),
      await load('lmroman10-bolditalic'),
      await load('lmroman12-bold'),
      await load('lmroman9-regular'),
      await load('lmroman9-italic'),
      await load('FontAwesome5-Solid'),
      await load('FontAwesome5-Brands'),
      pw.MemoryImage(
          (await rootBundle.load('assets/cv_fonts/profile-placeholder.png'))
              .buffer
              .asUint8List()),
    );
  }

  Future<void> shareOrDownload(CvProfileModel cv) async {
    final bytes = await buildPdf(cv);
    await Printing.sharePdf(bytes: bytes, filename: _fileName(cv));
  }

  Future<PreparedFile> prepareForUpload(CvProfileModel cv) async {
    final bytes = await buildPdf(cv);
    return PreparedFile(
        bytes: bytes, fileName: _fileName(cv), mimeType: 'application/pdf');
  }

  String _fileName(CvProfileModel cv) {
    final rawName = cv.fullName.trim().isEmpty
        ? 'career_bridge_cv'
        : '${cv.fullName.trim()}_CV';
    return '${rawName.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_')}.pdf';
  }

  pw.MemoryImage? _profilePhoto(String dataUrl) {
    final value = dataUrl.trim();
    if (value.isEmpty) return null;
    try {
      final payload = value.startsWith('data:')
          ? value.substring(value.indexOf(',') + 1)
          : value;
      return pw.MemoryImage(base64Decode(payload));
    } catch (_) {
      // A damaged optional photo must not prevent exporting the rest of the CV.
      return null;
    }
  }

  pw.TextSpan _icon(int code,
          {bool brand = false,
          double size = _contactSize,
          PdfColor color = PdfColors.black,
          double baseline = 0}) =>
      pw.TextSpan(children: [
        pw.TextSpan(
            text: String.fromCharCode(code),
            baseline: baseline,
            style: pw.TextStyle(
                font: brand ? _fonts!.brands : _fonts!.icons,
                fontNormal: brand ? _fonts!.brands : _fonts!.icons,
                fontSize: size,
                color: color)),
        const pw.TextSpan(text: ' '),
      ]);

  pw.Widget _header(CvProfileModel cv, pw.MemoryImage photo, _CvFonts fonts,
      {bool compact = false}) {
    final contacts = <pw.InlineSpan>[];
    if (cv.phone.trim().isNotEmpty) {
      contacts.addAll([
        _icon(0xf095),
        _link(cv.phone.trim(), 'tel:${cv.phone.replaceAll(RegExp(r'\s'), '')}')
      ]);
    }
    if (cv.email.trim().isNotEmpty) {
      contacts.addAll([
        if (contacts.isNotEmpty) const pw.TextSpan(text: '    '),
        _icon(0xf0e0),
        _link(cv.email.trim(), 'mailto:${cv.email.trim()}')
      ]);
    }
    final links = <pw.InlineSpan>[];
    if (cv.linkedInUrl.trim().isNotEmpty) {
      links.addAll([
        _icon(0xf08c, brand: true),
        _link(_displayUrl(cv.linkedInUrl), cv.linkedInUrl)
      ]);
    }
    if (cv.portfolioUrl.trim().isNotEmpty) {
      links.addAll([
        if (links.isNotEmpty) const pw.TextSpan(text: '    '),
        _icon(cv.portfolioUrl.contains('github.com') ? 0xf09b : 0xf0ac,
            brand: cv.portfolioUrl.contains('github.com')),
        _link(_displayUrl(cv.portfolioUrl), cv.portfolioUrl)
      ]);
    }
    final details = pw.RichText(
      overflow: pw.TextOverflow.span,
      text: _safeSpan(pw.TextSpan(
        style: pw.TextStyle(
            font: fonts.small,
            fontNormal: fonts.small,
            fontSize: _contactSize,
            lineSpacing: 3),
        children: [
          pw.TextSpan(
              text:
                  cv.fullName.trim().isEmpty ? 'Your Name' : cv.fullName.trim(),
              style: pw.TextStyle(
                  font: fonts.displayBold,
                  fontBold: fonts.displayBold,
                  fontSize: _nameSize,
                  fontWeight: pw.FontWeight.bold)),
          if (contacts.isNotEmpty) ...[
            const pw.TextSpan(text: '\n', style: pw.TextStyle(lineSpacing: 4)),
            ...contacts
          ],
          if (cv.location.trim().isNotEmpty) ...[
            const pw.TextSpan(text: '\n'),
            _icon(0xf3c5),
            pw.TextSpan(text: cv.location.trim())
          ],
          if (links.isNotEmpty) ...[const pw.TextSpan(text: '\n'), ...links],
        ],
      )),
    );
    return pw.Padding(
        padding: pw.EdgeInsets.only(top: compact ? 5 : 9.9626),
        child: pw.Partitions(children: [
          pw.Partition(flex: cv.showPhoto ? 72 : 100, child: details),
          if (cv.showPhoto) pw.Partition(flex: 6, child: _richText([])),
          if (cv.showPhoto)
            pw.Partition(
                flex: 22,
                child: pw.RichText(
                    textAlign: pw.TextAlign.right,
                    text: pw.WidgetSpan(
                        child: pw.SizedBox(
                            width: compact ? 65.0 : 73.7008,
                            height: compact ? 80 : 90.7087,
                            child: pw.Align(
                                alignment: pw.Alignment.topCenter,
                                child: pw.ClipOval(
                                    child: pw.Image(photo,
                                        width: compact ? 65.0 : 73.7008,
                                        height: compact ? 65.0 : 73.7008,
                                        fit: pw.BoxFit.cover))))))),
        ]));
  }

  String _displayUrl(String value) =>
      value.trim().replaceFirst(RegExp(r'^https?://'), '');

  List<pw.Widget> _sectionHeading(String title, {bool compact = false}) => [
        pw.NewPage(
            freeSpace: compact && title == 'Spoken Languages'
                ? 45
                : title == 'References' && !compact
                    ? 120
                    : 85),
        pw.Padding(
            // Match main.tex's 10pt before / 4pt after section spacing.
            padding: pw.EdgeInsets.only(
                top: (compact ? 6 : 10) * _texPoint,
                bottom: (compact ? 3 : 4) * _texPoint),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Text(title,
                      style: pw.TextStyle(
                          font: _fonts!.displayBold,
                          fontBold: _fonts!.displayBold,
                          fontSize: _headingSize,
                          fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: compact ? 3.5 : 5.4),
                  pw.Container(height: .5, color: PdfColors.black),
                  pw.SizedBox(height: 2),
                ])),
      ];

  // Both columns span pages, so unusually long user text remains exportable.
  pw.Widget _alignedRow(List<pw.InlineSpan> left, List<pw.InlineSpan> right,
      {double rightWidth = 164.4094}) {
    // A compact entry without a date can use the complete line for its issuer.
    if (right.isEmpty) {
      return pw.Padding(
          padding: const pw.EdgeInsets.only(right: 12, bottom: 3.1088),
          child: _richText(left));
    }
    return pw.Partitions(children: [
      pw.Partition(
          child: pw.Padding(
              padding: const pw.EdgeInsets.only(right: 12, bottom: 3.1088),
              child: _richText(left))),
      pw.Partition(
          width: rightWidth,
          child: pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3.1088),
              child: _richText(right, align: pw.TextAlign.right))),
    ]);
  }

  List<pw.Widget> _education(CvEducationItem item, {double bottom = 0}) => [
        _alignedRow([_bold(item.degree.trim())], [_bold(item.period.trim())]),
        _alignedRow([
          if (item.institutionUrl.trim().isEmpty)
            _italic(item.institution.trim(), color: _linkColor)
          else
            pw.TextSpan(
                text: item.institution.trim(),
                style: pw.TextStyle(
                    fontStyle: pw.FontStyle.italic, color: _linkColor),
                annotation: pw.AnnotationUrl(_url(item.institutionUrl))),
          if (item.institutionUrl.trim().isNotEmpty)
            _icon(0xf0c1, size: 5, baseline: 2.5),
        ], [
          _italic(item.location.trim())
        ]),
        if (item.result.trim().isNotEmpty || item.details.trim().isNotEmpty)
          pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2, bottom: 1),
              child: _bullet([
                ..._labeledDetail(item.result.trim(), 'Result'),
                if (item.result.trim().isNotEmpty &&
                    item.details.trim().isNotEmpty)
                  const pw.TextSpan(text: '    '),
                ..._labeledDetail(item.details.trim(), ''),
              ])),
        if (bottom > 0) pw.SizedBox(height: bottom),
      ];

  List<pw.InlineSpan> _labeledDetail(String value, String fallbackLabel) {
    if (value.isEmpty) {
      return [];
    }
    final colon = value.indexOf(':');
    if (colon > 0) {
      return [
        _bold(value.substring(0, colon + 1)),
        pw.TextSpan(text: value.substring(colon + 1))
      ];
    }
    return [
      if (fallbackLabel.isNotEmpty) _bold('$fallbackLabel: '),
      pw.TextSpan(text: value)
    ];
  }

  List<pw.Widget> _technicalSkills(CvProfileModel cv, {bool compact = false}) =>
      [
        for (final category in [
          ('Languages', cv.technicalLanguages),
          ('Frameworks', cv.frameworks),
          ('Tools & Platforms', cv.toolsAndPlatforms),
          ('Additional Skills', cv.skills),
        ])
          if (_values(category.$2).isNotEmpty)
            pw.Padding(
                padding: pw.EdgeInsets.only(bottom: compact ? 3 : 5.1088),
                child: pw.Partitions(children: [
                  pw.Partition(
                      width: 103.8, child: _richText([_bold(category.$1)])),
                  pw.Partition(
                      child: _richText([
                    pw.TextSpan(text: _values(category.$2).join(', '))
                  ])),
                ])),
      ];

  List<pw.Widget> _projectOrExperience({
    required String title,
    String link = '',
    String organization = '',
    String metadata = '',
    required String description,
    required double bottom,
  }) =>
      [
        pw.NewPage(freeSpace: 42),
        _alignedRow([
          _bold(title.trim()),
          if (link.trim().isNotEmpty) ...[
            const pw.TextSpan(text: ' | '),
            _icon(link.contains('github.com') ? 0xf09b : 0xf0c1,
                brand: link.contains('github.com'),
                size: _contactSize,
                color: _linkColor),
            _link('Source', link, fontSize: _contactSize)
          ],
          if (organization.trim().isNotEmpty) ...[
            const pw.TextSpan(text: ' | '),
            _italic(organization.trim())
          ],
        ], [
          pw.TextSpan(
              text: metadata.trim(),
              style: pw.TextStyle(
                  font: _fonts!.smallItalic,
                  fontItalic: _fonts!.smallItalic,
                  fontSize: _contactSize,
                  fontStyle: pw.FontStyle.italic))
        ]),
        if (description.trim().isNotEmpty) pw.SizedBox(height: 2 * _texPoint),
        ..._bullets(description),
        if (bottom > 0) pw.SizedBox(height: bottom),
      ];

  List<pw.Widget> _bullets(String description) {
    final lines = <String>[];
    final prefix = RegExp(r'^\s*(?:[•●◦▪‣⁃]\s*|[-*–—]\s+)');
    for (var line in description.split(RegExp(r'\r?\n'))) {
      line = line.trim();
      while (prefix.hasMatch(line)) {
        line = line.replaceFirst(prefix, '').trim();
      }
      if (line.isNotEmpty) lines.add(line);
    }
    return [
      for (var index = 0; index < lines.length; index++)
        _bullet([pw.TextSpan(text: lines[index])],
            bottom: index == lines.length - 1 ? 1 : 4.1088),
    ];
  }

  pw.Widget _bullet(List<pw.InlineSpan> spans, {double bottom = 1}) =>
      pw.Padding(
        padding: pw.EdgeInsets.only(left: 2.2137, bottom: bottom),
        child: pw.Partitions(children: [
          pw.Partition(
              width: 12.73, child: _richText([const pw.TextSpan(text: '•')])),
          pw.Partition(child: _richText(spans)),
        ]),
      );

  pw.Widget _reference(CvReferenceItem item, {double bottom = 0}) => _entry([
        _bold(item.name.trim()),
        if (item.designation.trim().isNotEmpty)
          pw.TextSpan(text: '\n${item.designation.trim()}'),
        if (item.organization.trim().isNotEmpty)
          pw.TextSpan(text: '\n${item.organization.trim()}'),
        if (item.email.trim().isNotEmpty) ...[
          const pw.TextSpan(text: '\n'),
          _icon(0xf0e0),
          _link(item.email.trim(), 'mailto:${item.email.trim()}'),
        ],
        if (item.phone.trim().isNotEmpty) ...[
          pw.TextSpan(text: item.email.trim().isEmpty ? '\n' : '  |  '),
          _link(item.phone.trim(),
              'tel:${item.phone.replaceAll(RegExp(r'\s'), '')}'),
        ],
      ], bottom: bottom);

  bool _hasText(List<String> values) =>
      values.any((value) => value.trim().isNotEmpty);
  List<String> _values(List<String> values) => values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList();
  pw.TextSpan _bold(String text) => pw.TextSpan(
      text: text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold));
  pw.TextSpan _italic(String text, {PdfColor? color}) => pw.TextSpan(
      text: text,
      style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: color));

  pw.TextSpan _link(String text, String url, {double? fontSize}) {
    final value = url.trim();
    return pw.TextSpan(
      text: text,
      style: pw.TextStyle(color: _linkColor, fontSize: fontSize),
      annotation: pw.AnnotationUrl(_url(value)),
    );
  }

  String _url(String value) => Uri.tryParse(value.trim())?.hasScheme == true
      ? value.trim()
      : 'https://${value.trim()}';

  // Normalize unsupported nonbreaking hyphens without changing stored data.
  String _printable(String value) => value.replaceAll('\u2011', '-');

  pw.InlineSpan _safeSpan(pw.InlineSpan span) {
    if (span is! pw.TextSpan) return span;
    return pw.TextSpan(
        text: span.text == null ? null : _printable(span.text!),
        style: span.style,
        baseline: span.baseline,
        annotation: span.annotation,
        children: span.children?.map(_safeSpan).toList());
  }

  pw.RichText _richText(List<pw.InlineSpan> spans,
          {double lineHeight = 1.2, pw.TextAlign align = pw.TextAlign.left}) =>
      pw.RichText(
        text: _safeSpan(pw.TextSpan(
            children: spans,
            style: pw.TextStyle(
                fontSize: _bodySize,
                lineSpacing: _bodySize * (lineHeight - .888)))),
        textAlign: align,
        overflow: pw.TextOverflow.span,
      );

  pw.Widget _entry(List<pw.InlineSpan> spans,
          {double bottom = 0, double lineHeight = 1.2}) =>
      pw.Padding(
        padding: pw.EdgeInsets.only(bottom: bottom),
        child: _richText(spans, lineHeight: lineHeight),
      );
}

class _CvFonts {
  const _CvFonts(
      this.regular,
      this.bold,
      this.italic,
      this.boldItalic,
      this.displayBold,
      this.small,
      this.smallItalic,
      this.icons,
      this.brands,
      this.placeholder);
  final pw.Font regular;
  final pw.Font bold;
  final pw.Font italic;
  final pw.Font boldItalic;
  final pw.Font displayBold;
  final pw.Font small;
  final pw.Font smallItalic;
  final pw.Font icons;
  final pw.Font brands;
  final pw.MemoryImage placeholder;
}
