@publishTestResults @dryRun @bypass-ado-integration
Feature: Dry-run support for publishing test results

Rule: Test results should not be published with dry-run mode

@tc:591
Scenario: Test results is published in dry-run mode
	Given there is a remote server project prepared for publishing test results
	And there is a feature file that was already synchronized before
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And there is a test result file with
		| name           | className                      | 
		| SampleScenario | MyProject.SampleFeatureFeature | 
	When the test result is published in dry-run mode
	Then the there should be no Test Run registered in Azure DevOps
