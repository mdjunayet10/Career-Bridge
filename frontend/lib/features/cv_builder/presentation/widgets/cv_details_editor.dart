import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/models/cv_profile_model.dart';

/// Shared profile and CV fields for applicants from any background.
class CvDetailsEditor extends StatefulWidget {
  const CvDetailsEditor({
    required this.profile,
    required this.onChanged,
    super.key,
  });

  final CvProfileModel profile;
  final ValueChanged<CvProfileModel> onChanged;

  @override
  State<CvDetailsEditor> createState() => _CvDetailsEditorState();
}

class _CvDetailsEditorState extends State<CvDetailsEditor> {
  late CvProfileModel _draft;
  CvProfileModel? _lastEmitted;
  int _nextId = 0;
  late List<int> _educationIds;
  late List<int> _projectIds;
  late List<int> _experienceIds;
  late List<int> _achievementIds;
  late List<int> _referenceIds;
  int _skillsVersion = 0;

  @override
  void initState() {
    super.initState();
    _reset(widget.profile);
  }

  @override
  void didUpdateWidget(CvDetailsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.profile, oldWidget.profile) &&
        !identical(widget.profile, _lastEmitted)) {
      _reset(widget.profile);
      _skillsVersion++;
    }
  }

  void _reset(CvProfileModel profile) {
    _draft = profile;
    _educationIds = List.generate(profile.education.length, (_) => _nextId++);
    _projectIds = List.generate(profile.projects.length, (_) => _nextId++);
    _experienceIds = List.generate(profile.experience.length, (_) => _nextId++);
    _achievementIds =
        List.generate(profile.achievements.length, (_) => _nextId++);
    _referenceIds = List.generate(profile.references.length, (_) => _nextId++);
  }

  void _emit(CvProfileModel profile) {
    setState(() {
      _draft = profile;
      _lastEmitted = profile;
    });
    widget.onChanged(profile);
  }

  List<String> _split(String value) => value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toSet()
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _section(
          title: 'Education',
          description: 'Add qualifications from any institution or background.',
          children: [
            for (var index = 0; index < _draft.education.length; index++)
              _educationRow(index),
            _addButton('Add education', () {
              _educationIds.add(_nextId++);
              _emit(_draft.copyWith(education: [
                ..._draft.education,
                const CvEducationItem(degree: '', institution: '', period: ''),
              ]));
            }),
          ],
        ),
        const SizedBox(height: 16),
        _section(
          title: 'Technical Skills',
          description:
              'Use commas between skills. Leave categories blank when they do not apply.',
          children: [
            _fields([
              TextFormField(
                key: ValueKey('technical-languages-$_skillsVersion'),
                initialValue: _draft.technicalLanguages.join(', '),
                decoration: const InputDecoration(
                  labelText: 'Languages',
                  hintText: 'Programming, query, or other technical languages',
                ),
                onChanged: (value) =>
                    _emit(_draft.copyWith(technicalLanguages: _split(value))),
              ),
              TextFormField(
                key: ValueKey('tools-platforms-$_skillsVersion'),
                initialValue: _draft.toolsAndPlatforms.join(', '),
                decoration: const InputDecoration(
                  labelText: 'Tools and Platforms',
                  hintText: 'Excel, AutoCAD, Photoshop, laboratory tools',
                ),
                onChanged: (value) =>
                    _emit(_draft.copyWith(toolsAndPlatforms: _split(value))),
              ),
              TextFormField(
                key: ValueKey('frameworks-$_skillsVersion'),
                initialValue: _draft.frameworks.join(', '),
                decoration: const InputDecoration(
                  labelText: 'Frameworks (optional)',
                ),
                onChanged: (value) =>
                    _emit(_draft.copyWith(frameworks: _split(value))),
              ),
            ]),
          ],
        ),
        const SizedBox(height: 16),
        _section(
          title: 'Projects',
          description:
              'Include relevant academic, professional, creative, or personal work.',
          children: [
            for (var index = 0; index < _draft.projects.length; index++)
              _projectRow(index),
            _addButton('Add project', () {
              _projectIds.add(_nextId++);
              _emit(_draft.copyWith(projects: [
                ..._draft.projects,
                const CvProjectItem(name: '', description: ''),
              ]));
            }),
          ],
        ),
        const SizedBox(height: 16),
        _section(
          title: 'Experience',
          description:
              'Add work, internships, freelance, research, or volunteer experience when relevant.',
          children: [
            for (var index = 0; index < _draft.experience.length; index++)
              _experienceRow(index),
            _addButton('Add experience', () {
              _experienceIds.add(_nextId++);
              _emit(_draft.copyWith(experience: [
                ..._draft.experience,
                const CvExperienceItem(
                    role: '', company: '', period: '', description: ''),
              ]));
            }),
          ],
        ),
        const SizedBox(height: 16),
        _section(
          title: 'Achievements & Certifications',
          description:
              'Add awards, accomplishments, and relevant certificates.',
          children: [
            for (var index = 0; index < _draft.achievements.length; index++)
              _achievementRow(index),
            _addButton('Add achievement or certification', () {
              _achievementIds.add(_nextId++);
              _emit(_draft.copyWith(achievements: [
                ..._draft.achievements,
                const CvAchievementItem(title: ''),
              ]));
            }),
          ],
        ),
        const SizedBox(height: 16),
        _section(
          title: 'References',
          description:
              'Add professional or academic references when available.',
          children: [
            for (var index = 0; index < _draft.references.length; index++)
              _referenceRow(index),
            _addButton('Add reference', () {
              _referenceIds.add(_nextId++);
              _emit(_draft.copyWith(references: [
                ..._draft.references,
                const CvReferenceItem(name: ''),
              ]));
            }),
          ],
        ),
      ],
    );
  }

  Widget _educationRow(int index) {
    final item = _draft.education[index];
    void update({
      String? degree,
      String? institution,
      String? institutionUrl,
      String? period,
      String? location,
      String? result,
      String? details,
    }) {
      final items = [..._draft.education];
      final current = items[index];
      items[index] = CvEducationItem(
        degree: degree ?? current.degree,
        institution: institution ?? current.institution,
        institutionUrl: institutionUrl ?? current.institutionUrl,
        period: period ?? current.period,
        location: location ?? current.location,
        result: result ?? current.result,
        details: details ?? current.details,
      );
      _emit(_draft.copyWith(education: items));
    }

    return _entry(
      key: ValueKey('education-${_educationIds[index]}'),
      title: 'Education ${index + 1}',
      onRemove: () {
        _educationIds.removeAt(index);
        final items = [..._draft.education]..removeAt(index);
        _emit(_draft.copyWith(education: items));
      },
      fields: [
        TextFormField(
          initialValue: item.degree,
          decoration:
              const InputDecoration(labelText: 'Degree / qualification'),
          onChanged: (value) => update(degree: value),
          validator: (value) => _entryTitle(value, [
            _draft.education[index].institution,
            _draft.education[index].institutionUrl,
            _draft.education[index].period,
            _draft.education[index].location,
            _draft.education[index].result,
            _draft.education[index].details,
          ]),
        ),
        TextFormField(
          initialValue: item.institution,
          decoration: const InputDecoration(labelText: 'Institution'),
          onChanged: (value) => update(institution: value),
        ),
        TextFormField(
          initialValue: item.institutionUrl,
          decoration: const InputDecoration(
              labelText: 'Institution website (optional)'),
          onChanged: (value) => update(institutionUrl: value),
        ),
        TextFormField(
          initialValue: item.period,
          decoration: const InputDecoration(labelText: 'Dates / period'),
          onChanged: (value) => update(period: value),
        ),
        TextFormField(
          initialValue: item.location,
          decoration: const InputDecoration(labelText: 'Location (optional)'),
          onChanged: (value) => update(location: value),
        ),
        TextFormField(
          initialValue: item.result,
          decoration: const InputDecoration(labelText: 'Result (optional)'),
          onChanged: (value) => update(result: value),
        ),
        TextFormField(
          initialValue: item.details,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'Details (optional)'),
          onChanged: (value) => update(details: value),
        ),
      ],
    );
  }

  Widget _projectRow(int index) {
    final item = _draft.projects[index];
    void update(
        {String? name,
        String? description,
        String? link,
        String? toolsAndMethods}) {
      final items = [..._draft.projects];
      final current = items[index];
      items[index] = CvProjectItem(
        name: name ?? current.name,
        description: description ?? current.description,
        link: link ?? current.link,
        toolsAndMethods: toolsAndMethods ?? current.toolsAndMethods,
      );
      _emit(_draft.copyWith(projects: items));
    }

    return _entry(
      key: ValueKey('project-${_projectIds[index]}'),
      title: 'Project ${index + 1}',
      onRemove: () {
        _projectIds.removeAt(index);
        final items = [..._draft.projects]..removeAt(index);
        _emit(_draft.copyWith(projects: items));
      },
      fields: [
        TextFormField(
          initialValue: item.name,
          decoration: const InputDecoration(labelText: 'Project name'),
          onChanged: (value) => update(name: value),
          validator: (value) => _entryTitle(value, [
            _draft.projects[index].description,
            _draft.projects[index].link,
            _draft.projects[index].toolsAndMethods,
          ]),
        ),
        TextFormField(
          initialValue: item.link,
          decoration:
              const InputDecoration(labelText: 'Project link (optional)'),
          onChanged: (value) => update(link: value),
        ),
        TextFormField(
          initialValue: item.toolsAndMethods,
          decoration:
              const InputDecoration(labelText: 'Tools / methods (optional)'),
          onChanged: (value) => update(toolsAndMethods: value),
        ),
        TextFormField(
          initialValue: item.description,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Project description',
            helperText: 'One bullet point per line.',
          ),
          onChanged: (value) => update(description: value),
        ),
      ],
    );
  }

  Widget _experienceRow(int index) {
    final item = _draft.experience[index];
    void update({
      String? role,
      String? company,
      String? period,
      String? description,
    }) {
      final items = [..._draft.experience];
      final current = items[index];
      items[index] = CvExperienceItem(
        role: role ?? current.role,
        company: company ?? current.company,
        period: period ?? current.period,
        description: description ?? current.description,
      );
      _emit(_draft.copyWith(experience: items));
    }

    return _entry(
      key: ValueKey('experience-${_experienceIds[index]}'),
      title: 'Experience ${index + 1}',
      onRemove: () {
        _experienceIds.removeAt(index);
        final items = [..._draft.experience]..removeAt(index);
        _emit(_draft.copyWith(experience: items));
      },
      fields: [
        TextFormField(
          initialValue: item.role,
          decoration: const InputDecoration(labelText: 'Role / position'),
          onChanged: (value) => update(role: value),
          validator: (value) => _entryTitle(value, [
            _draft.experience[index].company,
            _draft.experience[index].period,
            _draft.experience[index].description,
          ]),
        ),
        TextFormField(
          initialValue: item.company,
          decoration: const InputDecoration(labelText: 'Organization'),
          onChanged: (value) => update(company: value),
        ),
        TextFormField(
          initialValue: item.period,
          decoration:
              const InputDecoration(labelText: 'Experience dates / period'),
          onChanged: (value) => update(period: value),
        ),
        TextFormField(
          initialValue: item.description,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Experience description',
            helperText: 'One bullet point per line.',
          ),
          onChanged: (value) => update(description: value),
        ),
      ],
    );
  }

  Widget _achievementRow(int index) {
    final item = _draft.achievements[index];
    void update({
      String? title,
      String? qualifier,
      String? date,
      String? description,
    }) {
      final items = [..._draft.achievements];
      final current = items[index];
      items[index] = CvAchievementItem(
        title: title ?? current.title,
        qualifier: qualifier ?? current.qualifier,
        date: date ?? current.date,
        description: description ?? current.description,
      );
      _emit(_draft.copyWith(achievements: items));
    }

    return _entry(
      key: ValueKey('achievement-${_achievementIds[index]}'),
      title: 'Achievement / certification ${index + 1}',
      onRemove: () {
        _achievementIds.removeAt(index);
        final items = [..._draft.achievements]..removeAt(index);
        _emit(_draft.copyWith(achievements: items));
      },
      fields: [
        TextFormField(
          initialValue: item.title,
          decoration:
              const InputDecoration(labelText: 'Award or certificate title'),
          onChanged: (value) => update(title: value),
          validator: (value) => _entryTitle(value, [
            _draft.achievements[index].qualifier,
            _draft.achievements[index].date,
            _draft.achievements[index].description,
          ]),
        ),
        TextFormField(
          initialValue: item.qualifier,
          decoration: const InputDecoration(
              labelText: 'Issuer / organization (optional)'),
          onChanged: (value) => update(qualifier: value),
        ),
        TextFormField(
          initialValue: item.date,
          decoration: const InputDecoration(labelText: 'Date (optional)'),
          onChanged: (value) => update(date: value),
        ),
        TextFormField(
          initialValue: item.description,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Achievement description (optional)',
            helperText: 'One bullet point per line.',
          ),
          onChanged: (value) => update(description: value),
        ),
      ],
    );
  }

  Widget _referenceRow(int index) {
    final item = _draft.references[index];
    void update({
      String? name,
      String? designation,
      String? organization,
      String? email,
      String? phone,
    }) {
      final items = [..._draft.references];
      final current = items[index];
      items[index] = CvReferenceItem(
        name: name ?? current.name,
        designation: designation ?? current.designation,
        organization: organization ?? current.organization,
        email: email ?? current.email,
        phone: phone ?? current.phone,
      );
      _emit(_draft.copyWith(references: items));
    }

    return _entry(
      key: ValueKey('reference-${_referenceIds[index]}'),
      title: 'Reference ${index + 1}',
      onRemove: () {
        _referenceIds.removeAt(index);
        final items = [..._draft.references]..removeAt(index);
        _emit(_draft.copyWith(references: items));
      },
      fields: [
        TextFormField(
          initialValue: item.name,
          decoration: const InputDecoration(labelText: 'Name'),
          onChanged: (value) => update(name: value),
          validator: (value) => _entryTitle(value, [
            _draft.references[index].designation,
            _draft.references[index].organization,
            _draft.references[index].email,
            _draft.references[index].phone,
          ]),
        ),
        TextFormField(
          initialValue: item.designation,
          decoration:
              const InputDecoration(labelText: 'Designation (optional)'),
          onChanged: (value) => update(designation: value),
        ),
        TextFormField(
          initialValue: item.organization,
          maxLines: 3,
          decoration:
              const InputDecoration(labelText: 'Organization (optional)'),
          onChanged: (value) => update(organization: value),
        ),
        TextFormField(
          initialValue: item.email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email (optional)'),
          onChanged: (value) => update(email: value),
        ),
        TextFormField(
          initialValue: item.phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Phone (optional)'),
          onChanged: (value) => update(phone: value),
        ),
      ],
    );
  }

  String? _entryTitle(String? title, List<String> otherFields) =>
      (title ?? '').trim().isEmpty &&
              otherFields.any((value) => value.trim().isNotEmpty)
          ? 'Add a name or title for this entry'
          : null;

  Widget _section({
    required String title,
    required String description,
    required List<Widget> children,
  }) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: AppColors.borderMuted),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 5),
            Text(description,
                style:
                    const TextStyle(color: AppColors.textSubtle, fontSize: 11)),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      );

  Widget _entry({
    required Key key,
    required String title,
    required VoidCallback onRemove,
    required List<Widget> fields,
  }) =>
      Padding(
        key: key,
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(
                  child: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700))),
              IconButton(
                tooltip: 'Remove $title',
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
            ]),
            const SizedBox(height: 8),
            _fields(fields),
          ],
        ),
      );

  Widget _addButton(String label, VoidCallback onPressed) => Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.add),
          label: Text(label),
        ),
      );

  Widget _fields(List<Widget> fields) => LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 700 ? 2 : 1;
          final width = (constraints.maxWidth - (columns - 1) * 14) / columns;
          return Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final field in fields) SizedBox(width: width, child: field),
            ],
          );
        },
      );
}
