import '../../../core/enums/employer_verification_status.dart';
import '../../../core/enums/user_role.dart';
import 'models/app_user_model.dart';

/// Fictional, local-only accounts. Never provision these in Firebase.
abstract final class DemoAccountCatalog {
  static const password = 'Demo123!';
  static const accounts = <DemoAccountDefinition>[
    DemoAccountDefinition(
        uid: 'demo-job-seeker',
        name: 'Ayan Rahman (Demo)',
        email: 'jobseeker@careerbridge.demo',
        role: UserRole.jobSeeker,
        roleTitle: 'Flutter Developer',
        category: 'Technology',
        location: 'Dhaka',
        skills: ['Flutter', 'Dart', 'Firebase', 'Git'],
        education: 'Computer Science',
        project: 'Accessible Campus App'),
    DemoAccountDefinition(
        uid: 'demo-seeker-designer',
        name: 'Mira Sen (Demo)',
        email: 'designer@careerbridge.demo',
        role: UserRole.jobSeeker,
        roleTitle: 'Product Designer',
        category: 'Design',
        location: 'Chattogram',
        skills: ['Figma', 'UX Research', 'Prototyping', 'Design Systems'],
        education: 'Design',
        project: 'Community Services Redesign'),
    DemoAccountDefinition(
        uid: 'demo-seeker-analyst',
        name: 'Tariq Noor (Demo)',
        email: 'analyst@careerbridge.demo',
        role: UserRole.jobSeeker,
        roleTitle: 'Junior Data Analyst',
        category: 'Data & Analytics',
        location: 'Dhaka',
        skills: ['SQL', 'Python', 'Power BI', 'Excel'],
        education: 'Statistics',
        project: 'Sample Retail Dashboard'),
    DemoAccountDefinition(
        uid: 'demo-seeker-accountant',
        name: 'Farah Kabir (Demo)',
        email: 'accountant@careerbridge.demo',
        role: UserRole.jobSeeker,
        roleTitle: 'Junior Accountant',
        category: 'Finance',
        location: 'Rajshahi',
        skills: ['Accounting', 'Excel', 'Bookkeeping', 'Reporting'],
        education: 'Accounting',
        project: 'Nonprofit Budget Planner'),
    DemoAccountDefinition(
        uid: 'demo-seeker-marketer',
        name: 'Nabil Karim (Demo)',
        email: 'marketer@careerbridge.demo',
        role: UserRole.jobSeeker,
        roleTitle: 'Digital Marketing Executive',
        category: 'Marketing',
        location: 'Dhaka',
        skills: ['SEO', 'Campaign Planning', 'Analytics', 'Copywriting'],
        education: 'Marketing',
        project: 'Community Library Campaign'),
    DemoAccountDefinition(
        uid: 'demo-seeker-civil',
        name: 'Ritu Das (Demo)',
        email: 'civil@careerbridge.demo',
        role: UserRole.jobSeeker,
        roleTitle: 'Civil Engineering Trainee',
        category: 'Engineering',
        location: 'Gazipur',
        skills: ['AutoCAD', 'Quantity Surveying', 'Site Safety', 'Excel'],
        education: 'Civil Engineering',
        project: 'Rainwater Collection Plan'),
    DemoAccountDefinition(
        uid: 'demo-seeker-support',
        name: 'Samiha Roy (Demo)',
        email: 'support@careerbridge.demo',
        role: UserRole.jobSeeker,
        roleTitle: 'Customer Support Specialist',
        category: 'Customer Support',
        location: 'Sylhet',
        skills: ['Customer Service', 'CRM', 'Troubleshooting', 'Communication'],
        education: 'Business Administration',
        project: 'Help Centre Knowledge Base'),
    DemoAccountDefinition(
        uid: 'demo-seeker-hr',
        name: 'Adnan Saha (Demo)',
        email: 'hr@careerbridge.demo',
        role: UserRole.jobSeeker,
        roleTitle: 'HR Coordinator',
        category: 'Human Resources',
        location: 'Dhaka',
        skills: [
          'Recruitment',
          'HR Operations',
          'Excel',
          'Interview Scheduling'
        ],
        education: 'Human Resource Management',
        project: 'Volunteer Onboarding Toolkit'),
    DemoAccountDefinition(
        uid: 'demo-seeker-writer',
        name: 'Lina Chowdhury (Demo)',
        email: 'writer@careerbridge.demo',
        role: UserRole.jobSeeker,
        roleTitle: 'Content Writer',
        category: 'Creative',
        location: 'Barishal',
        skills: ['Content Writing', 'Editing', 'Research', 'SEO'],
        education: 'English',
        project: 'Local Heritage Story Collection'),
    DemoAccountDefinition(
        uid: 'demo-seeker-qa',
        name: 'Rafiq Alam (Demo)',
        email: 'qa@careerbridge.demo',
        role: UserRole.jobSeeker,
        roleTitle: 'Software QA Engineer',
        category: 'Technology',
        location: 'Sylhet',
        skills: ['QA', 'Postman', 'Test Cases', 'Regression Testing'],
        education: 'Computer Science',
        project: 'Demo Booking Test Suite'),
    DemoAccountDefinition(
        uid: 'demo-seeker-operations',
        name: 'Nora Islam (Demo)',
        email: 'operations@careerbridge.demo',
        role: UserRole.jobSeeker,
        roleTitle: 'Operations Coordinator',
        category: 'Operations',
        location: 'Chattogram',
        skills: ['Logistics', 'Inventory', 'Excel', 'Process Mapping'],
        education: 'Supply Chain Management',
        project: 'Community Delivery Simulation'),
    DemoAccountDefinition(
        uid: 'demo-seeker-energy',
        name: 'Ishan Dey (Demo)',
        email: 'energy@careerbridge.demo',
        role: UserRole.jobSeeker,
        roleTitle: 'Energy Analyst Intern',
        category: 'Engineering',
        location: 'Khulna',
        skills: ['Energy Modelling', 'Excel', 'Sustainability', 'Research'],
        education: 'Electrical Engineering',
        project: 'Solar Rooftop Feasibility Study'),
    DemoAccountDefinition(
        uid: 'demo-seeker-backend',
        name: 'Rehan Pal (Demo)',
        email: 'backend@careerbridge.demo',
        role: UserRole.jobSeeker,
        roleTitle: 'Backend Developer',
        category: 'Technology',
        location: 'Dhaka',
        skills: ['Node.js', 'PostgreSQL', 'REST APIs', 'Docker'],
        education: 'Computer Science',
        project: 'Public Library API'),
    DemoAccountDefinition(
        uid: 'demo-seeker-teacher',
        name: 'Tania Dey (Demo)',
        email: 'teacher@careerbridge.demo',
        role: UserRole.jobSeeker,
        roleTitle: 'Teaching Assistant',
        category: 'Education',
        location: 'Rangpur',
        skills: ['Lesson Planning', 'Communication', 'Assessment', 'Research'],
        education: 'Education',
        project: 'Accessible Science Lessons'),
    DemoAccountDefinition(
        uid: 'demo-seeker-nurse',
        name: 'Afsana Sen (Demo)',
        email: 'nurse@careerbridge.demo',
        role: UserRole.jobSeeker,
        roleTitle: 'Nursing Graduate',
        category: 'Healthcare',
        location: 'Rajshahi',
        skills: [
          'Patient Communication',
          'Care Planning',
          'Documentation',
          'First Aid'
        ],
        education: 'Nursing',
        project: 'Community Care Awareness Guide'),
    DemoAccountDefinition(
        uid: 'demo-seeker-researcher',
        name: 'Omar Roy (Demo)',
        email: 'researcher@careerbridge.demo',
        role: UserRole.jobSeeker,
        roleTitle: 'Research Assistant',
        category: 'Research',
        location: 'Dhaka',
        skills: ['Research', 'Python', 'Documentation', 'Data Collection'],
        education: 'Economics',
        project: 'Sample Community Survey'),
    DemoAccountDefinition(
        uid: 'demo-seeker-sales',
        name: 'Priya Alam (Demo)',
        email: 'sales@careerbridge.demo',
        role: UserRole.jobSeeker,
        roleTitle: 'Sales Executive',
        category: 'Sales',
        location: 'Chattogram',
        skills: ['Sales', 'CRM', 'Negotiation', 'Communication'],
        education: 'Business Administration',
        project: 'Local Enterprise Sales Plan'),
    DemoAccountDefinition(
        uid: 'demo-seeker-graphic',
        name: 'Rayan Saha (Demo)',
        email: 'graphic@careerbridge.demo',
        role: UserRole.jobSeeker,
        roleTitle: 'Graphic Designer',
        category: 'Design',
        location: 'Sylhet',
        skills: ['Illustrator', 'Typography', 'Figma', 'Layout Design'],
        education: 'Fine Arts',
        project: 'Community Arts Identity'),
    DemoAccountDefinition(
        uid: 'demo-seeker-food',
        name: 'Dina Noor (Demo)',
        email: 'food@careerbridge.demo',
        role: UserRole.jobSeeker,
        roleTitle: 'Food Quality Assistant',
        category: 'Quality Assurance',
        location: 'Mymensingh',
        skills: ['Quality Control', 'Food Safety', 'Documentation', 'Excel'],
        education: 'Food Engineering',
        project: 'Sample Produce Quality Checklist'),
    DemoAccountDefinition(
        uid: 'demo-seeker-electrical',
        name: 'Kabir Das (Demo)',
        email: 'electrical@careerbridge.demo',
        role: UserRole.jobSeeker,
        roleTitle: 'Electrical Engineering Trainee',
        category: 'Engineering',
        location: 'Khulna',
        skills: ['Circuit Design', 'AutoCAD', 'Safety', 'Testing'],
        education: 'Electrical Engineering',
        project: 'Low Voltage Lighting Prototype'),
    DemoAccountDefinition(
        uid: 'demo-employer-approved',
        name: 'Nusrat Hasan (Demo)',
        email: 'employer@careerbridge.demo',
        role: UserRole.employer,
        roleTitle: 'Flutter Developer',
        category: 'Technology',
        location: 'Dhaka',
        skills: ['Flutter', 'Dart', 'Firebase', 'Git'],
        companyId: 'demo-novatech-bangladesh',
        companyName: 'NovaTech Bangladesh (Demo)',
        industry: 'Software & Product',
        verificationStatus: EmployerVerificationStatus.approved),
    DemoAccountDefinition(
        uid: 'demo-employer-pending',
        name: 'Arif Sen (Demo)',
        email: 'pending@careerbridge.demo',
        role: UserRole.employer,
        roleTitle: 'Research Assistant',
        category: 'Research',
        location: 'Dhaka',
        skills: ['Research', 'Python', 'Documentation'],
        companyId: 'demo-orbit-labs',
        companyName: 'Orbit Labs (Demo)',
        industry: 'Research & Innovation',
        verificationStatus: EmployerVerificationStatus.pending),
    DemoAccountDefinition(
        uid: 'demo-employer-bengal',
        name: 'Maliha Noor (Demo)',
        email: 'bengal@careerbridge.demo',
        role: UserRole.employer,
        roleTitle: 'Junior Data Analyst',
        category: 'Data & Analytics',
        location: 'Dhaka',
        skills: ['SQL', 'Python', 'Power BI'],
        companyId: 'demo-bengal-dataworks',
        companyName: 'Bengal DataWorks (Demo)',
        industry: 'Data & Analytics',
        verificationStatus: EmployerVerificationStatus.approved),
    DemoAccountDefinition(
        uid: 'demo-employer-summit',
        name: 'Fahim Roy (Demo)',
        email: 'summit@careerbridge.demo',
        role: UserRole.employer,
        roleTitle: 'Web Developer',
        category: 'Technology',
        location: 'Chattogram',
        skills: ['JavaScript', 'React', 'Git'],
        companyId: 'demo-summitlabs-digital',
        companyName: 'SummitLabs Digital (Demo)',
        industry: 'Mobile & Web Development',
        verificationStatus: EmployerVerificationStatus.approved),
    DemoAccountDefinition(
        uid: 'demo-employer-greengrid',
        name: 'Rina Karim (Demo)',
        email: 'greengrid@careerbridge.demo',
        role: UserRole.employer,
        roleTitle: 'Energy Analyst Intern',
        category: 'Engineering',
        location: 'Khulna',
        skills: ['Sustainability', 'Excel', 'Research'],
        companyId: 'demo-greengrid-energy',
        companyName: 'GreenGrid Energy (Demo)',
        industry: 'Energy & Sustainability',
        verificationStatus: EmployerVerificationStatus.approved),
    DemoAccountDefinition(
        uid: 'demo-employer-carenest',
        name: 'Imran Saha (Demo)',
        email: 'carenest@careerbridge.demo',
        role: UserRole.employer,
        roleTitle: 'Customer Support Specialist',
        category: 'Customer Support',
        location: 'Rajshahi',
        skills: ['Customer Service', 'CRM', 'Troubleshooting'],
        companyId: 'demo-carenest-health',
        companyName: 'CareNest Health (Demo)',
        industry: 'Health Technology',
        verificationStatus: EmployerVerificationStatus.approved),
    DemoAccountDefinition(
        uid: 'demo-employer-pixel',
        name: 'Sara Dey (Demo)',
        email: 'pixel@careerbridge.demo',
        role: UserRole.employer,
        roleTitle: 'Product Designer',
        category: 'Design',
        location: 'Remote',
        skills: ['Figma', 'UX Research', 'Prototyping'],
        companyId: 'demo-pixelharbor-studio',
        companyName: 'PixelHarbor Studio (Demo)',
        industry: 'Design & Digital Products',
        verificationStatus: EmployerVerificationStatus.approved),
    DemoAccountDefinition(
        uid: 'demo-employer-ledger',
        name: 'Tanvir Sen (Demo)',
        email: 'ledger@careerbridge.demo',
        role: UserRole.employer,
        roleTitle: 'Junior Accountant',
        category: 'Finance',
        location: 'Rajshahi',
        skills: ['Accounting', 'Excel', 'Bookkeeping'],
        companyId: 'demo-ledgerleaf-finance',
        companyName: 'LedgerLeaf Finance (Demo)',
        industry: 'Accounting & Advisory',
        verificationStatus: EmployerVerificationStatus.approved),
    DemoAccountDefinition(
        uid: 'demo-employer-story',
        name: 'Amina Roy (Demo)',
        email: 'story@careerbridge.demo',
        role: UserRole.employer,
        roleTitle: 'Content Writer',
        category: 'Creative',
        location: 'Barishal',
        skills: ['Content Writing', 'Editing', 'SEO'],
        companyId: 'demo-storyspring-media',
        companyName: 'StorySpring Media (Demo)',
        industry: 'Creative & Marketing',
        verificationStatus: EmployerVerificationStatus.approved),
    DemoAccountDefinition(
        uid: 'demo-employer-people',
        name: 'Mahin Das (Demo)',
        email: 'people@careerbridge.demo',
        role: UserRole.employer,
        roleTitle: 'HR Coordinator',
        category: 'Human Resources',
        location: 'Dhaka',
        skills: ['Recruitment', 'HR Operations', 'Excel'],
        companyId: 'demo-peoplepath-consulting',
        companyName: 'PeoplePath Consulting (Demo)',
        industry: 'Human Resources',
        verificationStatus: EmployerVerificationStatus.approved),
    DemoAccountDefinition(
        uid: 'demo-employer-build',
        name: 'Nadia Alam (Demo)',
        email: 'build@careerbridge.demo',
        role: UserRole.employer,
        roleTitle: 'Civil Engineering Trainee',
        category: 'Engineering',
        location: 'Gazipur',
        skills: ['AutoCAD', 'Quantity Surveying', 'Site Safety'],
        companyId: 'demo-buildbloom-engineering',
        companyName: 'BuildBloom Engineering (Demo)',
        industry: 'Construction & Engineering',
        verificationStatus: EmployerVerificationStatus.approved),
    DemoAccountDefinition(
        uid: 'demo-employer-harbor',
        name: 'Faisal Noor (Demo)',
        email: 'harbor@careerbridge.demo',
        role: UserRole.employer,
        roleTitle: 'Operations Coordinator',
        category: 'Operations',
        location: 'Chattogram',
        skills: ['Logistics', 'Inventory', 'Process Mapping'],
        companyId: 'demo-harborlink-logistics',
        companyName: 'HarborLink Logistics (Demo)',
        industry: 'Logistics & Operations',
        verificationStatus: EmployerVerificationStatus.approved),
  ];

  static DemoAccountDefinition? byEmail(String email) {
    final normalized = email.trim().toLowerCase();
    for (final account in accounts) {
      if (account.email == normalized) return account;
    }
    return null;
  }

  static DemoAccountDefinition? byUid(String uid) {
    for (final account in accounts) {
      if (account.uid == uid) return account;
    }
    return null;
  }

  static List<DemoAccountDefinition> forRole(UserRole role) =>
      accounts.where((account) => account.role == role).toList(growable: false);
}

class DemoAccountDefinition {
  const DemoAccountDefinition({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.roleTitle,
    required this.category,
    required this.location,
    required this.skills,
    this.education = '',
    this.project = '',
    this.companyId = '',
    this.companyName = '',
    this.industry = '',
    this.verificationStatus = EmployerVerificationStatus.notRequired,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String roleTitle;
  final String category;
  final String location;
  final List<String> skills;
  final String education;
  final String project;
  final String companyId;
  final String companyName;
  final String industry;
  final EmployerVerificationStatus verificationStatus;

  String get jobId => uid == 'demo-employer-approved'
      ? 'flutter-developer-novatech'
      : '$companyId-opportunity';
  bool get isPending =>
      verificationStatus == EmployerVerificationStatus.pending;

  AppUserModel get user => AppUserModel(
        uid: uid,
        name: name,
        email: email,
        role: role,
        isActive: true,
        companyName: role == UserRole.employer ? companyName : null,
        verificationStatus: verificationStatus,
        createdAt: DateTime(2026, 11, 1),
      );
}
