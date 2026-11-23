import 'models/company_model.dart';

abstract final class CompaniesDemoData {
  static const companies = <CompanyModel>[
    CompanyModel(
      id: 'novatech-bangladesh',
      name: 'NovaTech Bangladesh',
      industry: 'Software & Product',
      location: 'Dhaka',
      size: '51–200 employees',
      founded: '2018',
      description:
          'NovaTech builds mobile and web products for growing businesses in Bangladesh and Southeast Asia. The team focuses on practical engineering, modern product design, and long-term client partnerships.',
      specialties: [
        'Flutter',
        'Web Platforms',
        'Cloud Products',
        'Product Design'
      ],
      openings: 2,
      website: 'novatech.example',
    ),
    CompanyModel(
      id: 'pixelforge-studio',
      name: 'PixelForge Studio',
      industry: 'Design & Digital Products',
      location: 'Remote · Bangladesh',
      size: '11–50 employees',
      founded: '2020',
      description:
          'PixelForge is a remote-first product design studio helping startups shape clear, useful digital experiences through research, interaction design, and design systems.',
      specialties: [
        'Product Design',
        'UX Research',
        'Design Systems',
        'Brand Experience'
      ],
      openings: 1,
      website: 'pixelforge.example',
    ),
    CompanyModel(
      id: 'datanest-ltd',
      name: 'DataNest Ltd.',
      industry: 'Data & Analytics',
      location: 'Dhaka',
      size: '51–200 employees',
      founded: '2017',
      description:
          'DataNest helps retail, logistics, and financial teams turn operational data into dashboards, forecasting tools, and better day-to-day decisions.',
      specialties: [
        'Analytics',
        'Business Intelligence',
        'Data Platforms',
        'Reporting'
      ],
      openings: 3,
      website: 'datanest.example',
    ),
    CompanyModel(
      id: 'shopup',
      name: 'ShopUp',
      industry: 'Commerce & Fintech',
      location: 'Dhaka',
      size: '1000+ employees',
      founded: '2016',
      description:
          'ShopUp builds commerce, logistics, and financial services that help small businesses across Bangladesh operate and grow more effectively.',
      specialties: ['Commerce', 'Logistics', 'Fintech', 'Growth'],
      openings: 1,
      website: 'shopup.com.bd',
    ),
    CompanyModel(
      id: 'bkash',
      name: 'bKash',
      industry: 'Financial Technology',
      location: 'Dhaka',
      size: '1000+ employees',
      founded: '2011',
      description:
          'bKash provides mobile financial services across Bangladesh and builds secure, accessible digital payment experiences for millions of people and businesses.',
      specialties: ['Fintech', 'Payments', 'Financial Services', 'Technology'],
      openings: 1,
      website: 'bkash.com',
    ),
    CompanyModel(
      id: 'brain-station-23',
      name: 'Brain Station 23',
      industry: 'Software & IT Services',
      location: 'Dhaka',
      size: '500+ employees',
      founded: '2006',
      description:
          'Brain Station 23 delivers software engineering, cloud, and digital transformation services for clients in Bangladesh and international markets.',
      specialties: [
        'Software Engineering',
        'Cloud',
        'Enterprise Platforms',
        'Quality Assurance'
      ],
      openings: 1,
      website: 'brainstation-23.com',
    ),
    CompanyModel(
      id: 'pathao',
      name: 'Pathao',
      industry: 'Technology & Logistics',
      location: 'Dhaka · Nationwide',
      size: '1000+ employees',
      founded: '2015',
      description:
          'Pathao operates technology-powered mobility, delivery, and logistics services that connect people, merchants, and businesses across Bangladesh.',
      specialties: [
        'Logistics',
        'Mobility',
        'Operations',
        'Consumer Technology'
      ],
      openings: 1,
      website: 'pathao.com',
    ),
    CompanyModel(
      id: 'buildwell-engineering',
      name: 'BuildWell Engineering',
      industry: 'Construction & Engineering',
      location: 'Gazipur',
      size: '201–500 employees',
      founded: '2012',
      description:
          'BuildWell delivers commercial and industrial construction projects with an emphasis on quality, safety, and reliable execution.',
      specialties: [
        'Civil Engineering',
        'Construction',
        'Project Management',
        'Safety'
      ],
      openings: 2,
    ),
    CompanyModel(
      id: 'cloudly-bd',
      name: 'Cloudly BD',
      industry: 'SaaS & Cloud Services',
      location: 'Remote · Bangladesh',
      size: '11–50 employees',
      founded: '2021',
      description:
          'Cloudly creates simple cloud software for small businesses and supports customers through onboarding, automation, and practical service.',
      specialties: ['SaaS', 'Customer Success', 'Cloud Tools', 'Support'],
      openings: 3,
    ),
    CompanyModel(
      id: 'peoplefirst-consulting',
      name: 'PeopleFirst Consulting',
      industry: 'Human Resources',
      location: 'Dhaka',
      size: '11–50 employees',
      founded: '2019',
      description:
          'PeopleFirst supports growing organisations with recruitment, people operations, training, and practical HR systems.',
      specialties: [
        'Recruitment',
        'HR Operations',
        'Training',
        'Employer Branding'
      ],
      openings: 2,
    ),
    CompanyModel(
      id: 'storylab-bangladesh',
      name: 'StoryLab Bangladesh',
      industry: 'Creative & Marketing',
      location: 'Dhaka',
      size: '11–50 employees',
      founded: '2018',
      description:
          'StoryLab creates digital campaigns, brand stories, and employer communications for local and regional clients.',
      specialties: [
        'Content',
        'Digital Campaigns',
        'Brand Strategy',
        'Creative Services'
      ],
      openings: 1,
    ),
    CompanyModel(
      id: 'techverse-labs',
      name: 'TechVerse Labs',
      industry: 'Software Quality & Engineering',
      location: 'Sylhet',
      size: '51–200 employees',
      founded: '2016',
      description:
          'TechVerse builds and tests web and mobile products for international clients from its engineering hub in Sylhet.',
      specialties: [
        'Quality Assurance',
        'Web Development',
        'Mobile Apps',
        'Automation'
      ],
      openings: 2,
    ),
    // Fictional companies for an SDP 2 demonstration. Never represent these
    // as verified employers or live job listings.
    CompanyModel(
      id: 'demo-bengal-dataworks',
      name: 'Bengal DataWorks (Demo)',
      industry: 'Data & Analytics',
      location: 'Dhaka',
      size: '11–50 employees',
      founded: '2025',
      description:
          'Fictional academic-demo company providing data reporting, analytics and dashboards for sample hiring flows.',
      specialties: ['Analytics', 'SQL', 'Business Intelligence'],
      openings: 2,
      website: 'example.com',
    ),
    CompanyModel(
      id: 'demo-summitlabs-digital',
      name: 'SummitLabs Digital (Demo)',
      industry: 'Mobile & Web Development',
      location: 'Chattogram',
      size: '11–50 employees',
      founded: '2025',
      description:
          'Fictional academic-demo software studio used to demonstrate job search, CV matching and application tracking.',
      specialties: ['Flutter', 'Web Development', 'UI/UX'],
      openings: 2,
      website: 'example.com',
    ),
    CompanyModel(
      id: 'demo-greengrid-energy',
      name: 'GreenGrid Energy (Demo)',
      industry: 'Energy & Sustainability',
      location: 'Khulna',
      size: '51–200 employees',
      founded: '2024',
      description:
          'Fictional academic-demo company showing energy-sector recruitment and internship opportunities.',
      specialties: ['Engineering', 'Sustainability', 'Operations'],
      openings: 1,
      website: 'example.com',
    ),
    CompanyModel(
      id: 'demo-carenest-health',
      name: 'CareNest Health (Demo)',
      industry: 'Health Technology',
      location: 'Rajshahi',
      size: '11–50 employees',
      founded: '2025',
      description:
          'Fictional academic-demo healthcare technology startup for showing non-clinical software roles.',
      specialties: ['Health Technology', 'Product Support', 'QA'],
      openings: 1,
      website: 'example.com',
    ),
  ];

  static CompanyModel? byId(String id) {
    for (final company in companies) {
      if (company.id == id) return company;
    }
    return null;
  }

  static List<String> get industries {
    final values = companies.map((company) => company.industry).toSet().toList()
      ..sort();
    return values;
  }
}
