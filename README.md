# Building a SAP CAP Application in the SAP Business Application Studio using the example of a student’s exam registration

Building a SAP CAP Application in the SAP Business Application Studio using the example of a student’s exam registration

In relation to a university module named „ERP-Systeme implementieren und erweitern“ (translates to „implement and expand ERP systems“) at the FH Aachen held by Christian Drumm I had to build a SAP CAP Application in the SAP Business Application. I made us of a SAP Fiori Elements Frontend. The task in the lecture reuied the module to at least make use of:

A SAP CAP backend
A SAP Fiori UI
Optionally additional SAP CP Services
Regarding that we had to come up with a scenario that would make use of these components. I came up with idea of simulating an university student’s exam registration.

I also added the project to a github repository: https://github.com/danijelos/ERP-QIS

In the following sections I will first describe the scenario I made us of in detail. After that I am going to show the developing steps beginning with creating a project. Furthermore I will explain how to build a database model, how to add sample data and how to display the data on the frontend with services. Following that I show you how to build a persistent database and how to build a SAP Fiori UI with the help of annotations. Last but not least I will go into how to build actions and how to use them with javascript.

The exam registration scenario

The business scenario is basically a very simple version of an exam registration from a university student. There is one student who needs to register for an exam. There are a lot of exams and the student has to know which exam he really wants to participate in. When the student decided that he wants to register for an exam, he clicks on it and registers. Now the program has to check whether the exam has requirements such as the student must have already passed another exam. If he can not fulfill the requirements, the program shows the student a negative notification. On the other hand if the requirements are met, the student receives a positive notification and the program records the exam registration in the database. At the end the student can register for more exams or he can log out.

The whole scenario is shown in the following BPMN-Diagram:



How does the workflow translate into the program? The data of the exams and the students is defined in a cds-file and later deployed to a SQL-file. The overview of the exams is implemented in a SAP Fiori UI. Last but not least the logic, i.e. checking the prerequisites and updating the database is implemented in java script.

Developing steps

Please note that before you can start working, you have to create a new dev space for the SAP Business Application Studio. The new dev space should be of type SAP Cloud Business Application. In addition to the standard extensions also the Workflow Management extension needs to be activated for this dev space.

Detailed Information if needed: https://cap.cloud.sap/docs/get-started/tools#bastudio

For the first developing steps I use some explanations of Prof. Dr. Christian Drumm, which you can also find here in a more detailled way: https://github.com/ceedee666/erp_scp_end_2_end/blob/master/docs/rqk_survey.md

Initializing the CAP project

In my project I often worked with the CDS command line tool. In order to use it I had to open a terminal window. To open a new terminal window right click on the empty projects pane and select „Open in Terminal“.



 

 

 

 

 

 

To initialize the QIS application I executed the following command: „cds i qis“. The result is an empty CAP project generated inside the qis folder which contains the „app“, „db“ and „srv“ folder, the „package.json“ file and the „README.MD“ file.



To finish the initial setup I had to install the required node.js modules. To install the required modules I executed „npm install“ in the project directory.

Developing the database model

After the empty project has been created the next step is to define the data model.  In CAP data models are defined using Core Data Services (CDS).

First of all I want to provide the ER-Diagram of the data model:



In order to generate the data model for the QIS application I created a file with the name „schema.cds“ in the „db“ folder of the project. I added the following CDS code to the schema.cds file.

using { cuid, managed } from '@sap/cds/common';

namespace de.fhaachen.qis;
entity Students : managed {
  key StudentID: Integer; 
  matriculationnumber : Integer;
  firstname   : String(500);
  lastname   : String(500);
  email   : String(500);
  degreecourse   : String(500);
}
entity Exams : managed {
  key ExamID: Integer; 
  modulnumber : String(500);
  examname   : String(500);
  examiner   : String(500);
  examdate   : Date;
  requirements   : Boolean;
  examrequirement : Integer;
}
entity StudentExam : managed {
    StudentID : Association to Students;
    ExamID : Association to Exams;
    modulnumber : Association to Exams;
    studentregistered : Boolean;
    exampassed : Boolean;
}
The CDS code above defines the entities that I needed for my application. CDS is a declarative description of a data model. Using the cds command line tools of CAP this declarative can be compiled into different data models. In my project I wanted to use SQL so the following command line compiles it into SQL: „cds c db/schema.cds -2 sql“. The result of the execution is shown in the terminal. The „managed“ aspect results in the four columns „createdAt, createdBy, changedAt and createdBy“.

Sample data in SQLite

In order to review and test my code, sample data is very useful checking for mistakes because you have something to work with. For adding sample data to the application three steps were necessary.

I had to add a folder „data“ to the „db“ folder
I had to add three files named „de.fhaachen.qis-Exams.csv“ and „de.fhaachen.qis-Students.csv“ and de.fhaachen.qis-StudentExam.csv“. „qis“ is the name of the folder and „Students, StudentExams and Exams“ are the entity names. CSV stands for „Comma-separated values“ and describes the structure of a text file for storing or exchanging simply structured data.
At last I had to put data in the csv files
Exams:

ExamID,modulnumber,examname,examiner,examdate,requirements,examrequirement,ID
1,10000,ERP,Drumm,2020-01-20,false,0,beaa103b-2030-43f7-a2f0-d03d8d0363eb
2,10001,Fortgeschrittenes Controlling,Bassen-Metz,2020-01-21,true,8,2c091bd2-d067-46fe-a3f8-da5480bdc6fd
3,10002,Digitalisierung und Innovation,Ritz,2020-01-22,false,0,ad7bbf25-1754-441a-9298-118862268c1c
4,10003,Fortgeschrittenes Marketing,Vieth,2020-01-23,true,7,68d5b5e2-541b-46e3-a059-0a2459696f5d
5,10004,Interdisziplinäres Projekt,Eggert,2020-01-24,false,0,dab4884b-6df5-4e1b-978b-7de83f9b980f
6,10005,Recht,Schwiering,2020-01-25,false,0,2394efa7-2d22-45b9-b109-ebda9ce1f0c5
7,10006,Einführung in das Marketing,Vieth,2020-01-20,false,0,71a6d915-d1c7-4b1c-b94b-e89259e2d8fa
8,10007,Einführung in das Controlling,Bassen-Metz,2020-01-21,false,0,02d06f94-c6af-40c1-87a7-ec8927352fe8
9,10008,Höhere Mathematik,Hoever,2020-01-22,false,0,299b62b9-3aeb-4ce0-96fb-9b723ac4a387
10,10009,Grundlagen der Programmiersprache,Classen,2020-01-23,false,0,e424226a-d608-4651-83c1-0697153e1134
11,10010,Informationsmanagement,Eggert,2020-01-24,false,0,32a39a56-1fdd-4718-add7-3b35b5dda6b2
12,10011,Kostenrechnung,Bassen-Metz,2020-01-25,false,0,cedf7f7c-f891-45de-bfa3-44287fdb92ea
Students:

StudentID,matriculationnumber,firstname,lastname,email,degreecourse
1,3201001,Daniel,Becker,daniel.becker@alumni.fh-aachen.de,Wirtschaftsinformatik
StudentExam

StudentID_StudentID,ExamID_ExamID,studentregistered,exampassed,ExamID_ID
1,1,true,false,beaa103b-2030-43f7-a2f0-d03d8d0363eb
1,2,false,false,2c091bd2-d067-46fe-a3f8-da5480bdc6fd
1,3,true,false,ad7bbf25-1754-441a-9298-118862268c1c
1,4,false,false,68d5b5e2-541b-46e3-a059-0a2459696f5d
1,5,false,false,dab4884b-6df5-4e1b-978b-7de83f9b980f
1,6,false,false,2394efa7-2d22-45b9-b109-ebda9ce1f0c5
1,7,false,false,71a6d915-d1c7-4b1c-b94b-e89259e2d8fa
1,8,false,true,02d06f94-c6af-40c1-87a7-ec8927352fe8
1,9,false,true,299b62b9-3aeb-4ce0-96fb-9b723ac4a387
1,10,false,false,e424226a-d608-4651-83c1-0697153e1134
1,11,true,false,32a39a56-1fdd-4718-add7-3b35b5dda6b2
1,12,false,true,cedf7f7c-f891-45de-bfa3-44287fdb92ea
Implementing the first service

Every active thing in CAP is a service. This applies to the application services you define in your project, as well as technical services delivered a sparts of the CAP framework. First I will build basic services that expose the entities of the data models. Later I will add an action, too.

Currently I have not implemented any services yet. Therefore I added three files, „manage-exams.cds“, „manage-students.cds“ and „manage-studentexam.cds“, for three services to the „srv“ folder and added the following code into them.

manage-exams.cds

using { de.fhaachen.qis as qis } from '../db/schema';

service ExamsService {
 entity Exams as projection on qis.Exams
 excluding {createdBy, createdAt, modifiedBy, modifiedAt}}
manage-students.cds

using { de.fhaachen.qis as qis } from '../db/schema';
service StudentsService {
  @readonly entity Students as projection on qis.Students
  excluding {createdBy, createdAt, modifiedBy, modifiedAt};
}
manage-studentexam.cds

using { de.fhaachen.qis as qis } from '../db/schema';
service StudentExamService {
  @readonly entity StudentExam as projection on qis.StudentExam
  excluding {createdBy, createdAt, modifiedBy, modifiedAt}  where studentregistered = true;
  @readonly entity Exams as projection on qis.Exams
}
The CDS define services that expose the entities of the data models. Once the file is saved I used the command „cds watch“ to compile and run the files. Now the test environment during development is shown with the entities. Clicking on them serves the sample data from the CSV file using OData v4. By only defining a data model and a service CAP already provides the full OData v4 functionality.

If OData is unknown there is a really good explanation by DJ Adams: https://blogs.sap.com/2018/08/20/monday-morning-thoughts-odata/



Now you can see the three services that I added. By clicking on one of the links with the „…in Fiori“-ending the service shows what I added to the service. In this case I declared projections of the tables in the database. By clicking on „Exams …in Fiori“ for example we get the „Exams“-Entity shown with the sample data in .json format but without „createdBy, createdAt, modifiedBy, modifiedAt because we excluded them in the service:



When you click on the $metadata, you get the metadata of the service shown in a .xml file.

Persisting Data in a Database

The next step is to add a persistent database to our application and fill it with the created data, because when the preview of the application restarts at this moment changes to the data are lost. The reason is that the application is currently running using an in-memory database. A persistent database makes it easier for testing because once changed data is changed permanently saved in the database. SQLite is the database I used because it is suitable for local development and testing.

Adding SQLite support to the project is quite simple. It only requires executing the following command: „cds deploy –-to sqlite“. This command performs the following steps:

Creates an SQLite database file in your project.
Drops existing tables and views, and re-creates them according the CDS model.
Deploys CSV files with initial data.
Creates an entry in the package.json file
In the following step I added a SQLite connection which enables using the database tools in the App Studio. I achieved this by following the steps on the screenshot.



I selected „SQLite“ as the connection type. I provided the name „QIS Database“ and the path „qis/sqlite.db“ which is the path to the „sqlite.db“ file. I am now able to see the created database artifacts and view them.



Building the Frontend

The next step is to build a SAP Fiori List Report to make the data more human-readable. To build the SAP Fiori List Report I had to click on „View“ in the Taskbar, go to „Find command“ and search for „Yeoman UI Generators“. After that I selected „SAP Fiori elements application“.



Then I selected the „List Report Object Page“ and as a data source I used „Use a Local CAP Node.js Project“.



After that the following files and folders were created.



Furthermore I added this code to the „annotation.cds“ file to complete and extend the UI. It adjusts the presentation of the Fiori list report.

using ExamsService as service from '../../../srv/manage-exams';

annotate qis.Exams with @odata.draft.enabled;

annotate service.Exams with @(
    UI: {
        SelectionFields : [],
        // Presentation in the List Report
        LineItem: [
            {Value: modulnumber, Label: 'Modulnumber'},
            {Value: examname, Label: 'Exam-Name'},
            {Value: examdate, Label: 'Exam-Date'},
            {Value: examiner, Label: 'Examiner'},
        ],
        HeaderInfo: {TypeNamePlural: 'Exams'},
        PresentationVariant : {
            SortOrder : [
                {
                    $Type : 'Common.SortOrderType',
                    Property : modulnumber,
                    Descending : false,
                },
            ],
            Visualizations : ['@UI.LineItem',],
        },
    }    
);
Without the annotations you would have to add the columns first:



It also would have no rational arrangement:



With the help of the „LineItem“-Annotation only the attributes that I wanted to show are shown in the list report. Please have in mind that you have to click „Start“ so that data can be displayed.



The „HeaderInfo“ annotation does that on the frontend the count of the exams is shown. The „PresentationVariant“ and therefore the „SortOrder“ sorts the list in an ascending way.



After adding the annotations the frontend looks like this:



Building an Action

After I build the frontend, I wanted to build an action that has a „Register“-Button which allows the student to register for an exam if he fulfills the requirements. In order to do that, I had to add an action to the manage-exams.cds:

using { de.fhaachen.qis as qis } from '../db/schema';

service ExamsService {
 entity Exams as projection on qis.Exams
 excluding {createdBy, createdAt, modifiedBy, modifiedAt}
 actions {
    action submitRegistration ();
 } 
}
I also had to add a manage-exams.js file in the „/srv“ folder.

In the frontend I had to add the action to the annotation.cds at the LineItem:

LineItem: [
            {Value: modulnumber, Label: 'Modulnumber'},
            {Value: examname, Label: 'Exam-Name'},
            {Value: examdate, Label: 'Exam-Date'},
            {Value: examiner, Label: 'Examiner'},
            // Action to register for an exam
            {$Type: 'UI.DataFieldForAction', Label: 'Register',
             Action: 'ExamsService.submitRegistration', Inline: true}
        ],
You can now see the „Register“-Button on the right side and the final look of the page is completed. It looks like this:



Implementing the js-API of the submitRegistration-Action

Until now I only added the UI without backend functionallity. In order to make us oft he „Register“-Button I had to add the following code to the manage-exams.js file. The code implements the business logic that I presented at the beginning. If the student is already registered for an exam there is no need to register one more time. If the exam has no requirement the student get registered for an exam. Therefore if the exam has a requirement I had to check if that requirement is fulfilled. Is the requirement fulfilled the student gets registered for the exam, if it is not fulfilled an error message is shown.

Also seen here: https://github.com/danijelos/ERP-QIS/blob/main/srv/manage-exams.js

const cds = require('@sap/cds')

module.exports = cds.service.impl (function () {
    this.on ('submitRegistration', async req => {
        const {Exams} = cds.entities
        const {StudentExam} = cds.entities
        const [data] = req.params
        
        // u = student already registered for that exam?
        let u = await cds .transaction(req).run(
            SELECT.from(StudentExam, ['studentregistered'])
            .where({ExamID_ExamID:{'=':data.ExamID}}))

        // Is this student already registered for that exam? -> Error
        if (u[0].studentregistered == true) {
            req.error('You are already registered for this exam.')
        }
        //If student is not registered -> Continue
        else { 
            // n = requirements and examrequirements of the exam the student wants to register to
            let n = await cds .transaction(req).run(
            SELECT.from(Exams,['requirements', 'examrequirement'])
            .where({ExamID:{'=':data.ExamID}}))

            // Does the exam have a requirement?
            if (n[0].requirements == true) {
                // m = the exam the student had to pass before registering for the current
                let m = await cds .transaction(req).run(
                    SELECT.from(StudentExam, ['exampassed'])
                    .where({ExamID_ExamID:{'=':n[0].examrequirement}}))

                // Did the student pass the required exam -> register him for the current
                if (m[0].exampassed == true) {
                    let j = await cds .transaction(req).run(
                        UPDATE (StudentExam)
                        .set({
                            studentregistered: true
                        })
                        .where({
                            ExamID_ExamID: {'=': data.ExamID}
                    }))
                } else {//If the student did not pass the required exam -> Error
                    req.error('You do not fulfill the requirements for this exam.')
                }
            } 
            // If the exam does not have requirements just register the student to the exam
            else {
                let q = await cds .transaction(req).run(
                    UPDATE (StudentExam)
                    .set({
                    studentregistered: true
                    })
                    .where({
                        ExamID_ExamID: {'=': data.ExamID}
                }))
            }
        }        
    })
})
This Line

const [data] = req.params
pulls the ID and ExamID out of the action that is given automatically like a GET. The comments in the code should elucidate the functions of the individual code snippets.

I am now able to register a student to an exam while considering two events. The student does not meet the requirements or is even already registered for the exam.

Adding a Fiori List Report that shows the exams that the student did register to

In order to test if the backend functionallity worked properly and to present the registered exams I now build another Fiori List Report as I did in „Building the Frontend“. This is by no means necessary because you can check your results of the testing also in the persistent database but I thought it would be a nice add on. The difference comes with configuring the data source and service selection. I used „StudentExamService“ for this Frontend-Page:



For the entity selection I used „StudentExam“ as the Main entity:



I added the Exams entity into the StudentExamService and added a „where“-condition, that filters the exams which the student registered to.

using { de.fhaachen.qis as qis } from '../db/schema';
service StudentExamService {
  @readonly entity StudentExam as projection on qis.StudentExam
  excluding {createdBy, createdAt, modifiedBy, modifiedAt}  where studentregistered = true;
  @readonly entity Exams as projection on qis.Exams
}
Last but not least I had to add a „annotation.cds“-file in the recently created project. It is nearly the same code as in the other „annotation.cds“. „ExamID.“ works as a foreign key which can access the data in the „Exams“ database.

using StudentExamService as service from '../../srv/manage-studentexam';

annotate qis.StudentExam with @odata.draft.enabled;

annotate service.StudentExam with @(
    UI: {
        SelectionFields : [],
        // Presentation in the List Report
        LineItem: [
            {Value: ExamID.modulnumber, Label: 'Modulnumber'},
            {Value: ExamID.examname, Label: 'Exam-Name'},
            {Value: ExamID.examdate, Label: 'Exam-Date'},
            {Value: ExamID.examiner, Label: 'Examiner'},
        ],
        HeaderInfo: {TypeNamePlural: 'Registered Exams'},
        PresentationVariant : {
            Visualizations : ['@UI.LineItem',],
        },
    }    
);
We are now able to see the two project pages.



Clicking on the first link I get to the page in which a student can register himself for exams. The second one the link directs you to the page where the student can see his registered exams.



End

Thank you for reading my blog post. I hope it helps you to understand the SAP Business Application Studio, CAP and Fiori Elements and also how the individual components work together a bit better.

There are a few things missing that could be developed in further steps.

It would be nice if a student had to log in and therefore only data is shown that is associated to him. More sample would have to be added for different students.

One could also add a page in which the passed exams of a student are shown with grades, credit points and a calculated performance record.

If the program is supposed to be published you should add a non local database like SAP Hana. It is also important to think about possible security issues and how to close those and build security.
