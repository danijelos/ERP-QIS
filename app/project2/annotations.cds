using StudentExamService as service from '../../srv/manage-studentexam';

annotate rqk.StudentExam with @odata.draft.enabled;

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