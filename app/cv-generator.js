const ejs = require('ejs');
const fs = require('fs');

const vigil = {
    company: 'Vigil',
    companyLocation: 'United Kingdom',
    title: 'Software Engineer',
    period: 'Aug, 2022 - Jan, 2024',
    responsibilities: [
        'Managed an initiative to migrate a business pipeline from an On-Premise environment to Cloud (AWS) using Microservices and Serverless components;',
        'Built a business pipeline to automate video segmentation using AI, generate metadata  and remove reliance on an external supplier;',
        'Proposed a strategy to decommission components from a business pipeline by analyzing the architecture and components’ role;',
    ],
    techsUsed: [
        'Scala',
        'HTTP4S',
        'Cats',
        'Cats Effect',
        'AWS (Step Function, Lambda, S3, SQS, SNS)',
        'Terraform',
        'Docker',
        'RabbitMQ',
        'Kubernates',
    ]
}

const pbSoft = {
    company: 'PBSoft',
    companyLocation: 'Brazil',
    title: 'System Analyst',
    period: 'Jun, 2018 - Aug, 2022',
    responsibilities: [
        'We achieved 100% test coverage on new Backend features and a more modular code, due to implementing a new architecture using Functional Programming (FP) concepts and Object Oriented Patterns.',
        'Reduced a 7 hours process time to 2 hours by improving SQL queries and validation rules.',
        'Coordinated effectively a team of 6 developers as Tech Lead',
        'Managed several projects through all development phases.',
        'Developed and implemented the documentation for a column-based text file import process using Jekyll.',
        'Worked alongside another Developer to build a file validation process using Akka Actors that reduced max validation time from 24 hours to 7 hours;',
        'Improved validation rules using functional concepts',
    ],
    techsUsed: [
        'Scala',
        'Play Framework',
        'Slick',
        'SQL Server',
        'Postgres',
        'AngularJS',
        'Angular',
        'RabbitMQ',
        'Docker',
        'Akka Actors',        
    ]
}

const prospectVendas = {
    company: 'Prospect Vendas',
    companyLocation: 'Brazil',
    title: 'Freelancer',
    period: 'Nov, 2020 - Feb, 2022',
    responsibilities: [
        'Applications (WEB and Mobile) to prospect clients for bike dealers, using a concept called Sales Funnel.',
    ],
    techsUsed: [
        'React',
        'React Native',
        'Javascript',
        'NestJS',
        'HTML', 
        'CSS', 
        'PostgreSQL', 
        'GCP',
    ]
}

const nemesisContabilidade = {
    company: 'Nemesis Contabilidade',
    companyLocation: 'Brazil',
    title: 'Freelancer',
    period: 'Jun, 2019 - Aug, 2022',
    responsibilities: [
        'Built applications to support their business workflows',
    ],
    techsUsed: [
        'Scala', 
        'HTTP4s', 
        'Cats', 
        'Cats Effect', 
        'MongoDB', 
        'Java', 
        'Spring', 
        'PostgreSQL', 
        'Angular', 
        'HTML', 
        'CSS', 
        'S3', 
        'Thymeleaf',
    ]
}

const tcePb = {
    company: 'TCE-PB',
    companyLocation: 'Brazil',
    title: 'Software Development Internship',
    period: 'Jun, 2017 - Jun, 2018',
    responsibilities: [
        'Worked with another Internship to discover how to improve validation rules in the file validation process;',
        'Developed features using Scala, Play Framework and AngularJS',
    ],
    techsUsed: [
        'Scala', 
        'Play Framework', 
        'Slick', 
        'SQL Server', 
        'AngularJS',
    ]
};        

const curriculum = {
    name: 'Maxranderson Araújo',
    aboutMe: [
    `
        Passionate about solving problems using technology. 
        Focused on using the best techniques to make software cleaner and maintainable. 
        I am self-motivated and eager to learn everything I can from the business. 
        Able to manage a team and develop through all phases of software development, including requirements definition, design, architecture, testing and support.
    `
    ],
    experiencies: [vigil, pbSoft, prospectVendas, nemesisContabilidade, tcePb],
    mainTech: [
        'Scala',
        'Javascript/Typescript',
        'Java',
        'AWS',
        'Docker',
        'Kubernetes',
        'Terraform',
        'Elastic Stack (ELK)',
    ],
    education: [
        {
            institution: 'Institute of Higher Education of Paraíba',
            country: 'Brazil',
            title: "Bachelor's degree in Information Systems",
            period: '2014 - 2018'
        }
    ]
}

ejs.renderFile('./app/cv-template.ejs', curriculum, null, (err, str) => {
    if(err) throw err;
    fs.mkdirSync("./dist");
    fs.writeFileSync('./dist/index.html', str);
});