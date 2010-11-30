Readme.txt
Chen, Horton & Shaw AMT Worker Motivation Experiment


Last edited: 12/16/09 by ads




====================== General Notes and Comments: ============================

NA's vs. Missing values vs. unanswered questions:
	* = NA when questions were not in the subject's treatment
	NA = NA when subjects saw a question and did not answer or provided crap answer
        9999 = answer given was "not sure or unable to answer" (I later converted some of these to NA)



Coding Scheme:
	At the moment, documentation for all question and answer codes are in two additional files:
		"AMT_answerchoice_recodes.xls"
		"AMT_variable_names-key-071409.xls"

	Some questions and answer codes appear more than once - this is because some questions have been represented twice 
		Checkboxes:
			all answers in one cell (e.g. "1-2-3")
			dummy variables corresponding to whether or not each box was checked
		BTS:
			all answers in one cell (e.g. "90-5-5")
			single-cell variables corresponding to each answer (e.g. 90, 5, 5 in separate cells)
		Betting Percent and Percent Accurate:
			all answers in one cell
			single-cell variables corresponding to each answer


Additional Data Cleanup To Do:
	double check that all rows without workerID are not included in analysis 
		- these should not be attriters, just empty rows
	follow up w. Anita and Jason to 
		(1) get data on attriters
		(2) understand empty rows w. workerIDs and "MissingID" worker id's
	identify/label questions relevant for analysis based on codebook & Anita's recodes
	convert income into uniform national currency units (maybe using Crowdflower on Mturk?)
	clean out non numeric characters from income variable
	search for duplicate workerid's (should be none, but worth verifying b/c we should report)


Identifying remaining Scammers/Attriters/Bad Data:
	simple open-ended questions (like "born" and "sitename") provide built-in measures of lazy completion
	should these results be discounted? thrown out (as attriters)? 

