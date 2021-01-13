using { de.fhaachen.rqk as rqk } from '../db/schema';

service ExamsService {
 entity Exams as projection on rqk.Exams
 excluding {createdBy, createdAt, modifiedBy, modifiedAt}
 actions {
    action submitRegistration ();
 } 
}

/* Sachen für Cloud */
/* cds compile srv/ --to xsuaa > . /xs-security.json */
/* mbt build */
/* cf deploy mta_archives/rqk_1.0.0.mtar */
/*er nennt @requires in 'rqk-admin-new' um */ 