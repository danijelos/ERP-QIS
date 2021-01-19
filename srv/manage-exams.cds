using { de.fhaachen.qis as qis } from '../db/schema';

service ExamsService {
 entity Exams as projection on qis.Exams
 excluding {createdBy, createdAt, modifiedBy, modifiedAt}
 actions {
    action submitRegistration ();
 } 
}