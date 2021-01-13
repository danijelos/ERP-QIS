const cds = require('@sap/cds')

module.exports = cds.service.impl (function () {
    this.on ('submitRegistration', async req => {
        const {Exams} = cds.entities
        const {StudentExam} = cds.entities
        const [data] = req.params
        // to update exampassed for exams in the database for testing
        /*let e = await cds .transaction(req).run( UPDATE (StudentExam)
            .set({
                exampassed: false
            })
            .where({
                ExamID_ExamID: {'=': 7}
            }))*/
        // to update studentregistered for exams in the database for testing
        /*let r = await cds .transaction(req).run( UPDATE (StudentExam)
            .set({
                studentregistered: false
            })
            .where({
                ExamID_ExamID: {'=': 9}
            }))*/
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

