using { de.fhaachen.rqk as rqk } from '../db/schema';
service StudentsService {
  @readonly entity Students as projection on rqk.Students
  excluding {createdBy, createdAt, modifiedBy, modifiedAt};
}