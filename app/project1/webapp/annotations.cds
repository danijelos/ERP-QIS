using ExamsService as service from '../../../srv/manage-exams';

annotate rqk.Exams with @odata.draft.enabled;

annotate service.Exams with @(
	UI: {
        SelectionFields : [],
        // Presentation in the List Report
		LineItem: [
            {Value: modulnumber, Label: 'Modulnumber'},
			{Value: examname, Label: 'Exam-Name'},
            {Value: examdate, Label: 'Exam-Date'},
            {Value: examiner, Label: 'Examiner'},
            // Action to register for an exam
            {$Type: 'UI.DataFieldForAction', Label: 'Register',
             Action: 'ExamsService.submitRegistration', Inline: true}
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