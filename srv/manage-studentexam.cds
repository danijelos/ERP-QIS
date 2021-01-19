using { de.fhaachen.qis as qis } from '../db/schema';
service StudentExamService {
  @readonly entity StudentExam as projection on qis.StudentExam
  excluding {createdBy, createdAt, modifiedBy, modifiedAt}  where studentregistered = true;
  @readonly entity Exams as projection on qis.Exams
}