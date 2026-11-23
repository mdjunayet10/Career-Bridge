import 'models/job_model.dart';

abstract final class JobsDemoData {
  static const jobs = <JobModel>[
    JobModel(
      id: 'flutter-developer-novatech',
      companyId: 'novatech-bangladesh',
      companyName: 'NovaTech Bangladesh',
      title: 'Flutter Developer',
      category: 'Technology',
      location: 'Dhaka',
      workMode: 'Hybrid',
      employmentType: 'Full-time',
      experience: '2–3 years',
      salaryLabel: '৳45k–70k / month',
      salaryMax: 70000,
      postedLabel: '2 days ago',
      deadlineLabel: '28 Aug 2026',
      openings: 2,
      description:
          'Build polished cross-platform products for high-growth teams in Bangladesh. You will work closely with product, design, and backend engineers to ship reliable Flutter experiences.',
      responsibilities: [
        'Develop and maintain production Flutter applications for mobile and web.',
        'Translate product requirements and Figma-ready UI specifications into reusable widgets.',
        'Collaborate with designers, backend engineers, and QA throughout delivery.',
        'Improve performance, accessibility, and automated test coverage.',
      ],
      requirements: [
        'Strong Dart and Flutter fundamentals with at least two shipped projects.',
        'Experience with REST APIs, Firebase, Git, and responsive layouts.',
        'Good understanding of state management and clean code practices.',
        'Clear written and verbal communication skills.',
      ],
      benefits: [
        'Festival bonus',
        'Flexible hybrid schedule',
        'Learning budget',
        'Health support'
      ],
      skills: ['Flutter', 'Dart', 'Firebase', 'Git'],
      isFeatured: true,
    ),
    JobModel(
      id: 'product-designer-pixelforge',
      companyId: 'pixelforge-studio',
      companyName: 'PixelForge Studio',
      title: 'Product Designer',
      category: 'Design',
      location: 'Remote',
      workMode: 'Remote',
      employmentType: 'Full-time',
      experience: '1–3 years',
      salaryLabel: '৳40k–60k / month',
      salaryMax: 60000,
      postedLabel: '1 day ago',
      deadlineLabel: '30 Aug 2026',
      openings: 1,
      description:
          'Design thoughtful web and mobile products for local and international clients while working with a collaborative remote product team.',
      responsibilities: [
        'Own user flows, wireframes, prototypes, and high-fidelity interfaces.',
        'Run lightweight discovery and usability sessions.',
        'Maintain reusable components and design documentation.',
        'Partner with engineers during implementation and QA.',
      ],
      requirements: [
        'A portfolio showing end-to-end product thinking.',
        'Strong Figma, interaction design, and responsive design skills.',
        'Ability to communicate design trade-offs clearly.',
      ],
      benefits: [
        'Remote-first work',
        'Paid design tools',
        'Flexible hours',
        'Quarterly retreats'
      ],
      skills: ['Figma', 'UX Research', 'Prototyping', 'Design Systems'],
      isFeatured: true,
    ),
    JobModel(
      id: 'junior-data-analyst-datanest',
      companyId: 'datanest-ltd',
      companyName: 'DataNest Ltd.',
      title: 'Junior Data Analyst',
      category: 'Technology',
      location: 'Dhaka',
      workMode: 'Hybrid',
      employmentType: 'Full-time',
      experience: 'Entry level',
      salaryLabel: '৳35k–52k / month',
      salaryMax: 52000,
      postedLabel: '3 days ago',
      deadlineLabel: '24 Aug 2026',
      openings: 3,
      description:
          'Turn operational and customer data into clear reports that help teams make better product and business decisions.',
      responsibilities: [
        'Clean, validate, and analyse structured datasets.',
        'Create recurring dashboards and concise business reports.',
        'Support ad-hoc analysis for product and operations teams.',
      ],
      requirements: [
        'Comfort with spreadsheets and SQL fundamentals.',
        'Basic knowledge of Power BI, Tableau, or similar tools.',
        'Strong analytical thinking and attention to detail.',
      ],
      benefits: [
        'Mentorship',
        'Hybrid work',
        'Performance bonus',
        'Training allowance'
      ],
      skills: ['SQL', 'Excel', 'Power BI', 'Data Analysis'],
      isFeatured: true,
    ),
    JobModel(
      id: 'growth-marketing-executive-shopup',
      companyId: 'shopup',
      companyName: 'ShopUp',
      title: 'Growth Marketing Executive',
      category: 'Marketing',
      location: 'Dhaka',
      workMode: 'On-site',
      employmentType: 'Full-time',
      experience: '1–2 years',
      salaryLabel: '৳38k–58k / month',
      salaryMax: 58000,
      postedLabel: 'Today',
      deadlineLabel: '2 Sep 2026',
      openings: 2,
      description:
          'Plan and execute measurable growth campaigns for merchants and customers across Bangladesh.',
      responsibilities: [
        'Coordinate campaign planning across paid, owned, and partner channels.',
        'Track acquisition, activation, and retention metrics.',
        'Create briefs and work with content and design teams.',
      ],
      requirements: [
        'Hands-on digital marketing or growth experience.',
        'Comfort with analytics, reporting, and experimentation.',
        'Strong communication and project management skills.',
      ],
      benefits: [
        'Mobile allowance',
        'Festival bonus',
        'Lunch support',
        'Learning budget'
      ],
      skills: ['Digital Marketing', 'Analytics', 'Campaigns', 'Content'],
    ),
    JobModel(
      id: 'finance-officer-bkash',
      companyId: 'bkash',
      companyName: 'bKash',
      title: 'Finance Officer',
      category: 'Finance',
      location: 'Dhaka',
      workMode: 'On-site',
      employmentType: 'Full-time',
      experience: '2–4 years',
      salaryLabel: '৳50k–75k / month',
      salaryMax: 75000,
      postedLabel: '4 days ago',
      deadlineLabel: '26 Aug 2026',
      openings: 1,
      description:
          'Support financial reporting, reconciliation, and control processes for one of Bangladesh’s leading fintech platforms.',
      responsibilities: [
        'Prepare reconciliations and monthly reporting schedules.',
        'Support audit, compliance, and internal control activities.',
        'Coordinate with business teams to resolve financial variances.',
      ],
      requirements: [
        'BBA or MBA in Finance, Accounting, or a related field.',
        'Strong spreadsheet and reporting skills.',
        'Knowledge of accounting standards and controls.',
      ],
      benefits: [
        'Health coverage',
        'Festival bonus',
        'Provident fund',
        'Transport support'
      ],
      skills: ['Accounting', 'Excel', 'Reporting', 'Reconciliation'],
    ),
    JobModel(
      id: 'backend-engineer-brainstation23',
      companyId: 'brain-station-23',
      companyName: 'Brain Station 23',
      title: 'Backend Engineer',
      category: 'Technology',
      location: 'Dhaka',
      workMode: 'Hybrid',
      employmentType: 'Full-time',
      experience: '3–5 years',
      salaryLabel: '৳70k–110k / month',
      salaryMax: 110000,
      postedLabel: '2 days ago',
      deadlineLabel: '31 Aug 2026',
      openings: 2,
      description:
          'Design scalable backend services and APIs for enterprise and consumer products.',
      responsibilities: [
        'Develop reliable services and documented APIs.',
        'Review code and improve engineering standards.',
        'Work with DevOps and frontend teams on delivery and observability.',
      ],
      requirements: [
        'Professional experience with Node.js, Java, .NET, or a comparable backend stack.',
        'Strong database and API design fundamentals.',
        'Experience with testing and version control workflows.',
      ],
      benefits: [
        'Hybrid schedule',
        'Certification support',
        'Health coverage',
        'Performance bonus'
      ],
      skills: ['APIs', 'Databases', 'Backend', 'Git'],
    ),
    JobModel(
      id: 'operations-associate-pathao',
      companyId: 'pathao',
      companyName: 'Pathao',
      title: 'Operations Associate',
      category: 'Business',
      location: 'Chattogram',
      workMode: 'On-site',
      employmentType: 'Full-time',
      experience: '0–2 years',
      salaryLabel: '৳30k–42k / month',
      salaryMax: 42000,
      postedLabel: '5 days ago',
      deadlineLabel: '22 Aug 2026',
      openings: 4,
      description:
          'Coordinate local operations, partner support, and service quality for a fast-moving logistics team.',
      responsibilities: [
        'Monitor daily operational performance and resolve escalations.',
        'Coordinate with riders, merchants, and support teams.',
        'Prepare operational updates and improvement plans.',
      ],
      requirements: [
        'Strong coordination and communication skills.',
        'Comfort working with spreadsheets and operational metrics.',
        'Willingness to work on-site and solve time-sensitive issues.',
      ],
      benefits: [
        'Performance incentive',
        'Mobile allowance',
        'Festival bonus',
        'Career progression'
      ],
      skills: ['Operations', 'Excel', 'Communication', 'Problem Solving'],
    ),
    JobModel(
      id: 'civil-site-engineer-buildwell',
      companyId: 'buildwell-engineering',
      companyName: 'BuildWell Engineering',
      title: 'Civil Site Engineer',
      category: 'Engineering',
      location: 'Gazipur',
      workMode: 'On-site',
      employmentType: 'Full-time',
      experience: '2–4 years',
      salaryLabel: '৳42k–65k / month',
      salaryMax: 65000,
      postedLabel: '1 week ago',
      deadlineLabel: '20 Aug 2026',
      openings: 2,
      description:
          'Supervise site execution, safety, quality, and progress reporting for commercial construction projects.',
      responsibilities: [
        'Coordinate daily site activities and subcontractors.',
        'Check drawings, quantities, quality, and safety compliance.',
        'Prepare progress updates and material requirements.',
      ],
      requirements: [
        'BSc or Diploma in Civil Engineering.',
        'Relevant site supervision experience.',
        'Ability to read drawings and prepare basic reports.',
      ],
      benefits: [
        'Site allowance',
        'Accommodation support',
        'Festival bonus',
        'Insurance'
      ],
      skills: ['AutoCAD', 'Site Supervision', 'Quantity Surveying', 'Safety'],
    ),
    JobModel(
      id: 'customer-success-executive-cloudly',
      companyId: 'cloudly-bd',
      companyName: 'Cloudly BD',
      title: 'Customer Success Executive',
      category: 'Business',
      location: 'Remote',
      workMode: 'Remote',
      employmentType: 'Full-time',
      experience: '1–2 years',
      salaryLabel: '৳32k–48k / month',
      salaryMax: 48000,
      postedLabel: 'Today',
      deadlineLabel: '5 Sep 2026',
      openings: 3,
      description:
          'Help small-business customers adopt cloud software and receive timely, thoughtful support.',
      responsibilities: [
        'Onboard customers and guide product adoption.',
        'Respond to support requests and identify recurring issues.',
        'Share customer feedback with product and engineering teams.',
      ],
      requirements: [
        'Excellent Bangla and English communication skills.',
        'Comfort learning software products quickly.',
        'Customer-facing or support experience is preferred.',
      ],
      benefits: [
        'Remote work',
        'Internet allowance',
        'Flexible shifts',
        'Performance bonus'
      ],
      skills: ['Customer Success', 'Communication', 'SaaS', 'Support'],
    ),
    JobModel(
      id: 'hr-intern-peoplefirst',
      companyId: 'peoplefirst-consulting',
      companyName: 'PeopleFirst Consulting',
      title: 'HR Intern',
      category: 'Business',
      location: 'Dhaka',
      workMode: 'Hybrid',
      employmentType: 'Internship',
      experience: 'Student / Fresh graduate',
      salaryLabel: '৳15k–20k / month',
      salaryMax: 20000,
      postedLabel: '3 days ago',
      deadlineLabel: '18 Aug 2026',
      openings: 2,
      description:
          'Support recruitment coordination, employee records, and people operations while learning practical HR workflows.',
      responsibilities: [
        'Coordinate interview schedules and candidate communication.',
        'Maintain recruitment trackers and employee records.',
        'Support onboarding and internal engagement activities.',
      ],
      requirements: [
        'Current student or recent graduate in HR, Business, or a related field.',
        'Organised, dependable, and comfortable with spreadsheets.',
        'Strong communication and willingness to learn.',
      ],
      benefits: [
        'Mentorship',
        'Certificate',
        'Flexible schedule',
        'Potential full-time offer'
      ],
      skills: ['HR', 'Recruitment', 'Excel', 'Communication'],
    ),
    JobModel(
      id: 'content-writer-storylab',
      companyId: 'storylab-bangladesh',
      companyName: 'StoryLab Bangladesh',
      title: 'Content Writer',
      category: 'Marketing',
      location: 'Dhaka',
      workMode: 'Hybrid',
      employmentType: 'Part-time',
      experience: '1–2 years',
      salaryLabel: '৳22k–35k / month',
      salaryMax: 35000,
      postedLabel: '6 days ago',
      deadlineLabel: '21 Aug 2026',
      openings: 1,
      description:
          'Create clear, engaging content for digital campaigns, websites, and employer brands.',
      responsibilities: [
        'Write and edit website, campaign, and social content.',
        'Research topics and adapt tone for different audiences.',
        'Coordinate with design and account teams on delivery.',
      ],
      requirements: [
        'A strong Bangla and English writing portfolio.',
        'Ability to meet deadlines and respond to feedback.',
        'Basic SEO knowledge is a plus.',
      ],
      benefits: [
        'Hybrid work',
        'Flexible hours',
        'Creative mentorship',
        'Project bonus'
      ],
      skills: ['Copywriting', 'Content', 'SEO', 'Research'],
    ),
    JobModel(
      id: 'qa-engineer-techverse',
      companyId: 'techverse-labs',
      companyName: 'TechVerse Labs',
      title: 'QA Engineer',
      category: 'Technology',
      location: 'Sylhet',
      workMode: 'Hybrid',
      employmentType: 'Full-time',
      experience: '2–4 years',
      salaryLabel: '৳48k–72k / month',
      salaryMax: 72000,
      postedLabel: '2 days ago',
      deadlineLabel: '29 Aug 2026',
      openings: 2,
      description:
          'Own practical testing workflows for web and mobile products and help teams release with confidence.',
      responsibilities: [
        'Plan and execute functional, regression, and exploratory testing.',
        'Document defects with clear reproduction steps.',
        'Collaborate with developers to improve release quality.',
      ],
      requirements: [
        'Experience testing web or mobile applications.',
        'Good understanding of test cases, defect tracking, and APIs.',
        'Automation experience is preferred but not mandatory.',
      ],
      benefits: [
        'Hybrid work',
        'Training budget',
        'Festival bonus',
        'Health support'
      ],
      skills: ['QA', 'Testing', 'APIs', 'Automation'],
    ),
    // Fictional SDP 2 demonstration postings; not real hiring opportunities.
    JobModel(
      id: 'demo-flutter-summit',
      companyId: 'demo-summitlabs-digital',
      companyName: 'SummitLabs Digital (Demo)',
      title: 'Junior Flutter Developer (Demo)',
      category: 'Technology',
      location: 'Chattogram',
      workMode: 'Hybrid',
      employmentType: 'Internship',
      experience: 'Entry level',
      salaryLabel: '৳18k–25k / month',
      salaryMax: 25000,
      postedLabel: 'Demo listing',
      deadlineLabel: '18 Nov 2026',
      openings: 1,
      description:
          'Academic demonstration listing for Career Bridge SDP 2. This is a fictional company and is not a real vacancy.',
      responsibilities: [
        'Demonstrate role-specific tasks and expected work quality.',
        'Collaborate with a sample team on project activities.'
      ],
      requirements: [
        'Relevant foundation skills for the position.',
        'Ability to communicate clearly and learn with feedback.'
      ],
      benefits: ['Illustrative compensation for demonstration only'],
      skills: ['Flutter', 'Dart', 'Firebase'],
    ),
    JobModel(
      id: 'demo-web-summit',
      companyId: 'demo-summitlabs-digital',
      companyName: 'SummitLabs Digital (Demo)',
      title: 'Frontend Developer (Demo)',
      category: 'Technology',
      location: 'Remote',
      workMode: 'Remote',
      employmentType: 'Full-time',
      experience: '1–2 years',
      salaryLabel: '৳35k–50k / month',
      salaryMax: 50000,
      postedLabel: 'Demo listing',
      deadlineLabel: '20 Nov 2026',
      openings: 1,
      description:
          'Academic demonstration listing for Career Bridge SDP 2. This is a fictional company and is not a real vacancy.',
      responsibilities: [
        'Demonstrate role-specific tasks and expected work quality.',
        'Collaborate with a sample team on project activities.'
      ],
      requirements: [
        'Relevant foundation skills for the position.',
        'Ability to communicate clearly and learn with feedback.'
      ],
      benefits: ['Illustrative compensation for demonstration only'],
      skills: ['JavaScript', 'HTML', 'CSS', 'Git'],
    ),
    JobModel(
      id: 'demo-data-bengal',
      companyId: 'demo-bengal-dataworks',
      companyName: 'Bengal DataWorks (Demo)',
      title: 'Data Analyst Intern (Demo)',
      category: 'Technology',
      location: 'Dhaka',
      workMode: 'On-site',
      employmentType: 'Internship',
      experience: 'Entry level',
      salaryLabel: '৳16k–22k / month',
      salaryMax: 22000,
      postedLabel: 'Demo listing',
      deadlineLabel: '19 Nov 2026',
      openings: 1,
      description:
          'Academic demonstration listing for Career Bridge SDP 2. This is a fictional company and is not a real vacancy.',
      responsibilities: [
        'Demonstrate role-specific tasks and expected work quality.',
        'Collaborate with a sample team on project activities.'
      ],
      requirements: [
        'Relevant foundation skills for the position.',
        'Ability to communicate clearly and learn with feedback.'
      ],
      benefits: ['Illustrative compensation for demonstration only'],
      skills: ['SQL', 'Excel', 'Python'],
    ),
    JobModel(
      id: 'demo-bi-bengal',
      companyId: 'demo-bengal-dataworks',
      companyName: 'Bengal DataWorks (Demo)',
      title: 'Business Intelligence Associate (Demo)',
      category: 'Business',
      location: 'Dhaka',
      workMode: 'Hybrid',
      employmentType: 'Full-time',
      experience: '1–3 years',
      salaryLabel: '৳38k–55k / month',
      salaryMax: 55000,
      postedLabel: 'Demo listing',
      deadlineLabel: '24 Nov 2026',
      openings: 1,
      description:
          'Academic demonstration listing for Career Bridge SDP 2. This is a fictional company and is not a real vacancy.',
      responsibilities: [
        'Demonstrate role-specific tasks and expected work quality.',
        'Collaborate with a sample team on project activities.'
      ],
      requirements: [
        'Relevant foundation skills for the position.',
        'Ability to communicate clearly and learn with feedback.'
      ],
      benefits: ['Illustrative compensation for demonstration only'],
      skills: ['SQL', 'Power BI', 'Data Analysis'],
    ),
    JobModel(
      id: 'demo-operations-green',
      companyId: 'demo-greengrid-energy',
      companyName: 'GreenGrid Energy (Demo)',
      title: 'Operations Coordinator (Demo)',
      category: 'Operations',
      location: 'Khulna',
      workMode: 'On-site',
      employmentType: 'Full-time',
      experience: 'Entry level',
      salaryLabel: '৳28k–40k / month',
      salaryMax: 40000,
      postedLabel: 'Demo listing',
      deadlineLabel: '21 Nov 2026',
      openings: 1,
      description:
          'Academic demonstration listing for Career Bridge SDP 2. This is a fictional company and is not a real vacancy.',
      responsibilities: [
        'Demonstrate role-specific tasks and expected work quality.',
        'Collaborate with a sample team on project activities.'
      ],
      requirements: [
        'Relevant foundation skills for the position.',
        'Ability to communicate clearly and learn with feedback.'
      ],
      benefits: ['Illustrative compensation for demonstration only'],
      skills: ['Operations', 'Documentation', 'Excel'],
    ),
    JobModel(
      id: 'demo-qa-carenest',
      companyId: 'demo-carenest-health',
      companyName: 'CareNest Health (Demo)',
      title: 'Junior QA Engineer (Demo)',
      category: 'Technology',
      location: 'Rajshahi',
      workMode: 'Hybrid',
      employmentType: 'Full-time',
      experience: 'Entry level',
      salaryLabel: '৳32k–45k / month',
      salaryMax: 45000,
      postedLabel: 'Demo listing',
      deadlineLabel: '25 Nov 2026',
      openings: 1,
      description:
          'Academic demonstration listing for Career Bridge SDP 2. This is a fictional company and is not a real vacancy.',
      responsibilities: [
        'Demonstrate role-specific tasks and expected work quality.',
        'Collaborate with a sample team on project activities.'
      ],
      requirements: [
        'Relevant foundation skills for the position.',
        'Ability to communicate clearly and learn with feedback.'
      ],
      benefits: ['Illustrative compensation for demonstration only'],
      skills: ['QA', 'Test Cases', 'Mobile Testing'],
    ),
  ];

  static JobModel? byId(String id) {
    for (final job in jobs) {
      if (job.id == id) return job;
    }
    return null;
  }

  static List<JobModel> byCompany(String companyId) {
    return jobs.where((job) => job.companyId == companyId).toList();
  }

  static List<JobModel> get featured =>
      jobs.where((job) => job.isFeatured).toList();

  static List<String> get categories {
    final values = jobs.map((job) => job.category).toSet().toList()..sort();
    return values;
  }

  static List<String> get employmentTypes {
    final values = jobs.map((job) => job.employmentType).toSet().toList()
      ..sort();
    return values;
  }

  static List<String> get workModes {
    final values = jobs.map((job) => job.workMode).toSet().toList()..sort();
    return values;
  }
}
