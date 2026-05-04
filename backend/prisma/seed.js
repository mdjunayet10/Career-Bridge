const bcrypt = require("bcryptjs");
const { PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient();
const demoPassword = "demo1234";

function daysFromNow(days) {
  const date = new Date();
  date.setDate(date.getDate() + days);
  return date;
}

async function main() {
  const passwordHash = await bcrypt.hash(demoPassword, 12);

  await prisma.auditLog.deleteMany();
  await prisma.report.deleteMany();
  await prisma.savedJob.deleteMany();
  await prisma.application.deleteMany();
  await prisma.job.deleteMany();
  await prisma.salaryInsight.deleteMany();
  await prisma.company.deleteMany();
  await prisma.jobSeekerProfile.deleteMany();
  await prisma.user.deleteMany();

  const [admin, employer, employee] = await Promise.all([
    prisma.user.create({
      data: {
        name: "Career Bridge Admin",
        email: "admin@careerbridge.com",
        passwordHash,
        role: "ADMIN"
      }
    }),
    prisma.user.create({
      data: {
        name: "Career Bridge Demo Employer",
        email: "employer@careerbridge.com",
        passwordHash,
        role: "EMPLOYER"
      }
    }),
    prisma.user.create({
      data: {
        name: "Career Bridge Demo Employee",
        email: "employee@careerbridge.com",
        passwordHash,
        role: "JOB_SEEKER",
        jobSeekerProfile: {
          create: {
            headline: "Junior software developer",
            phone: "+8801700000000",
            location: "Dhaka",
            bio: "Entry-level developer focused on JavaScript, Node.js, and clean user experiences.",
            skills: ["JavaScript", "React", "Node.js", "SQL"],
            education: [
              {
                institution: "Dhaka City College",
                degree: "BSc in Computer Science",
                year: "2026"
              }
            ],
            experience: [
              {
                company: "Campus Project Lab",
                title: "Frontend Intern",
                duration: "6 months"
              }
            ],
            portfolioUrl: "https://careerbridge.local/portfolio/demo",
            linkedinUrl: "https://linkedin.com/in/careerbridge-demo",
            githubUrl: "https://github.com/mdjunayet10"
          }
        }
      }
    })
  ]);

  const companies = await Promise.all([
    prisma.company.create({
      data: {
        ownerUserId: employer.id,
        name: "Dhaka Tech Hub",
        industry: "Software",
        size: "51-200",
        location: "Dhaka",
        website: "https://dhakatechhub.example.com",
        description: "Product engineering company building web platforms for local businesses.",
        verified: true
      }
    }),
    prisma.company.create({
      data: {
        ownerUserId: employer.id,
        name: "BridgeStack",
        industry: "Cloud Services",
        size: "11-50",
        location: "Dhaka",
        website: "https://bridgestack.example.com",
        description: "API, automation, and cloud infrastructure services for startups.",
        verified: true
      }
    }),
    prisma.company.create({
      data: {
        ownerUserId: employer.id,
        name: "Insight Grid",
        industry: "Data Analytics",
        size: "11-50",
        location: "Chattogram",
        website: "https://insightgrid.example.com",
        description: "Analytics studio helping teams understand business and hiring data.",
        verified: false
      }
    })
  ]);

  const [dhakaTechHub, bridgeStack, insightGrid] = companies;

  const jobs = await prisma.$transaction([
    prisma.job.create({
      data: {
        companyId: dhakaTechHub.id,
        title: "Junior Frontend Developer",
        description: "Build and maintain responsive interfaces using modern JavaScript and component-based UI patterns.",
        requirements: ["Strong HTML, CSS, JavaScript fundamentals", "Basic React or Vue knowledge", "Familiar with Git workflow"],
        responsibilities: ["Build reusable UI components", "Collaborate with backend engineers", "Improve accessibility and performance"],
        location: "Dhaka",
        jobType: "Full-time",
        workplaceType: "ONSITE",
        experienceLevel: "Junior",
        salaryMin: 35000,
        salaryMax: 45000,
        deadline: daysFromNow(21)
      }
    }),
    prisma.job.create({
      data: {
        companyId: bridgeStack.id,
        title: "Backend Node.js Developer",
        description: "Design REST APIs, integrate databases, and improve backend reliability and performance.",
        requirements: ["Node.js and Express experience", "SQL database understanding", "API authentication basics"],
        responsibilities: ["Build Express services", "Maintain PostgreSQL-backed APIs", "Write tests for core workflows"],
        location: "Dhaka",
        jobType: "Full-time",
        workplaceType: "HYBRID",
        experienceLevel: "Mid",
        salaryMin: 55000,
        salaryMax: 80000,
        deadline: daysFromNow(28)
      }
    }),
    prisma.job.create({
      data: {
        companyId: insightGrid.id,
        title: "Data Analyst",
        description: "Analyze business datasets, prepare dashboards, and communicate trends to stakeholders.",
        requirements: ["Strong Excel and SQL", "Experience with BI dashboards", "Clear communication skills"],
        responsibilities: ["Prepare weekly dashboards", "Clean and model hiring data", "Present insights to clients"],
        location: "Chattogram",
        jobType: "Full-time",
        workplaceType: "REMOTE",
        experienceLevel: "Mid",
        salaryMin: 45000,
        salaryMax: 70000,
        deadline: daysFromNow(35)
      }
    }),
    prisma.job.create({
      data: {
        companyId: dhakaTechHub.id,
        title: "UI/UX Designer",
        description: "Design practical product screens, flows, and prototypes for web applications.",
        requirements: ["Figma portfolio", "Understanding of design systems", "User research basics"],
        responsibilities: ["Create wireframes and high-fidelity designs", "Maintain component libraries", "Review implemented screens"],
        location: "Dhaka",
        jobType: "Contract",
        workplaceType: "HYBRID",
        experienceLevel: "Junior",
        salaryMin: 30000,
        salaryMax: 60000,
        deadline: daysFromNow(18)
      }
    }),
    prisma.job.create({
      data: {
        companyId: bridgeStack.id,
        title: "DevOps Engineer",
        description: "Support deployment pipelines, monitoring, and infrastructure automation.",
        requirements: ["Linux basics", "Docker and CI/CD familiarity", "Cloud monitoring experience"],
        responsibilities: ["Maintain deployment workflows", "Improve observability", "Document runbooks"],
        location: "Dhaka",
        jobType: "Full-time",
        workplaceType: "REMOTE",
        experienceLevel: "Senior",
        salaryMin: 90000,
        salaryMax: 140000,
        deadline: daysFromNow(42)
      }
    }),
    prisma.job.create({
      data: {
        companyId: insightGrid.id,
        title: "QA Engineer",
        description: "Test web applications, document defects, and help teams ship reliable releases.",
        requirements: ["Manual testing fundamentals", "Basic API testing", "Bug reporting discipline"],
        responsibilities: ["Write test cases", "Run regression checks", "Coordinate release sign-off"],
        location: "Sylhet",
        jobType: "Full-time",
        workplaceType: "ONSITE",
        experienceLevel: "Junior",
        salaryMin: 28000,
        salaryMax: 50000,
        deadline: daysFromNow(24)
      }
    }),
    prisma.job.create({
      data: {
        companyId: dhakaTechHub.id,
        title: "React Intern",
        description: "Join a guided internship focused on production frontend basics.",
        requirements: ["JavaScript fundamentals", "Willingness to learn", "Portfolio or class project"],
        responsibilities: ["Fix UI issues", "Pair with senior developers", "Learn pull request workflow"],
        location: "Dhaka",
        jobType: "Internship",
        workplaceType: "ONSITE",
        experienceLevel: "Entry",
        salaryMin: 12000,
        salaryMax: 18000,
        deadline: daysFromNow(14)
      }
    }),
    prisma.job.create({
      data: {
        companyId: bridgeStack.id,
        title: "Product Support Engineer",
        description: "Support customers, triage technical issues, and work with engineers on fixes.",
        requirements: ["Customer communication", "Basic SQL", "Troubleshooting mindset"],
        responsibilities: ["Respond to support tickets", "Reproduce technical issues", "Maintain knowledge base articles"],
        location: "Rajshahi",
        jobType: "Part-time",
        workplaceType: "HYBRID",
        experienceLevel: "Junior",
        salaryMin: 22000,
        salaryMax: 35000,
        deadline: daysFromNow(30)
      }
    })
  ]);

  await prisma.salaryInsight.createMany({
    data: [
      {
        roleTitle: "Frontend Developer",
        location: "Dhaka",
        salaryMin: 30000,
        salaryMax: 70000,
        experienceLevel: "Junior to Mid",
        source: "Career Bridge seed benchmark"
      },
      {
        roleTitle: "Backend Developer",
        location: "Dhaka",
        salaryMin: 40000,
        salaryMax: 90000,
        experienceLevel: "Mid",
        source: "Career Bridge seed benchmark"
      },
      {
        roleTitle: "UI/UX Designer",
        location: "Dhaka",
        salaryMin: 25000,
        salaryMax: 65000,
        experienceLevel: "Junior to Mid",
        source: "Career Bridge seed benchmark"
      },
      {
        roleTitle: "Data Analyst",
        location: "Chattogram",
        salaryMin: 35000,
        salaryMax: 80000,
        experienceLevel: "Mid",
        source: "Career Bridge seed benchmark"
      },
      {
        roleTitle: "DevOps Engineer",
        location: "Remote",
        salaryMin: 55000,
        salaryMax: 110000,
        experienceLevel: "Mid to Senior",
        source: "Career Bridge seed benchmark"
      }
    ]
  });

  await prisma.application.createMany({
    data: [
      {
        jobId: jobs[0].id,
        applicantUserId: employee.id,
        resumeUrl: null,
        resumeOriginalName: "demo-cv.pdf",
        coverLetter: "I am excited to contribute to frontend product work at Dhaka Tech Hub.",
        status: "SUBMITTED"
      },
      {
        jobId: jobs[1].id,
        applicantUserId: employee.id,
        resumeUrl: null,
        resumeOriginalName: "demo-cv.pdf",
        coverLetter: "My Node.js and SQL practice projects match the backend role requirements.",
        status: "REVIEWED"
      },
      {
        jobId: jobs[2].id,
        applicantUserId: employee.id,
        resumeUrl: null,
        resumeOriginalName: "demo-cv.pdf",
        coverLetter: "I enjoy turning messy datasets into clear dashboard insights.",
        status: "SHORTLISTED"
      }
    ]
  });

  await prisma.savedJob.createMany({
    data: [
      {
        userId: employee.id,
        jobId: jobs[3].id
      },
      {
        userId: employee.id,
        jobId: jobs[4].id
      }
    ]
  });

  await prisma.report.create({
    data: {
      reporterUserId: employee.id,
      targetType: "JOB",
      targetId: jobs[7].id,
      reason: "Salary details should be verified before publishing.",
      status: "OPEN"
    }
  });

  await prisma.auditLog.create({
    data: {
      actorUserId: admin.id,
      action: "SEED_DATABASE",
      targetType: "SYSTEM",
      metadata: {
        demoUsers: ["admin@careerbridge.com", "employer@careerbridge.com", "employee@careerbridge.com"]
      }
    }
  });

  console.log("Career Bridge seed data created.");
  console.log("Demo accounts all use password: demo1234");
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
