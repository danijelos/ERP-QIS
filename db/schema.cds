using { cuid, managed } from '@sap/cds/common';

namespace de.fhaachen.qis;
entity Students : cuid, managed {
  key StudentID: Integer; 
  matriculationnumber : Integer;
  firstname   : String(500);
  lastname   : String(500);
  email   : String(500);
  degreecourse   : String(500);
}
entity Exams : cuid, managed {
  key ExamID: Integer; 
  modulnumber : String(500);
  examname   : String(500);
  examiner   : String(500);
  examdate   : Date;
  requirements   : Boolean;
  examrequirement : Integer;
}
entity StudentExam : cuid, managed {
    StudentID : Association to Students;
    ExamID : Association to Exams;
    modulnumber : Association to Exams;
    studentregistered : Boolean;
    exampassed : Boolean;
}