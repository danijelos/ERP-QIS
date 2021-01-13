using { de.fhaachen.rqk as rqk } from '../db/schema';
service StudentExamService {
  @readonly entity StudentExam as projection on rqk.StudentExam
  excluding {createdBy, createdAt, modifiedBy, modifiedAt}  where studentregistered = true;
  @readonly entity Exams as projection on rqk.Exams
}