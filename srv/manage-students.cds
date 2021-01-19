using { de.fhaachen.qis as qis } from '../db/schema';
service StudentsService {
  @readonly entity Students as projection on qis.Students
  excluding {createdBy, createdAt, modifiedBy, modifiedAt};
}