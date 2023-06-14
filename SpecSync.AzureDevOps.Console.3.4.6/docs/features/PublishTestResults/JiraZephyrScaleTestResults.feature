@notsupported-tfs2017 @notsupported-tfs2018 @notsupported-ado2019 @notsupported-ado2020 @notsupported-ado2022 @notsupported-ado @notsupported-stub
Feature: Jira Zephyr Scale specific test result publishing details

Rule: Additional Test Cycle settigns can be specified

Supported Test Cycle settings:
- Description
- Iteration
- Folder
- Version

Supported Test Result settings:
- Comment
- Environment
(- Iteration)
(- Folder)

@tc:823
Scenario: Test Cycle settings are specified
	Given there is a remote server project prepared for publishing test results
	And there is a feature file that was already synchronized before
		"""
		Feature: Sample feature
		
		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And there is a test result file with
		| name           | className                      | outcome |
		| SampleScenario | MyProject.SampleFeatureFeature | Passed  |
	And the synchronizer is configured as
		| setting                                        | value                  |
		| publishTestResults/testRunSettings/name        | My test cycle          |
		| publishTestResults/testRunSettings/description | This is my description |
		| publishTestResults/testRunSettings/iteration   | Iteration 1            |
		| publishTestResults/testRunSettings/folder      | /TestCycleFolder1      |
		| publishTestResults/testRunSettings/version     | 1.2.3                  |
	When the test result is published successfully
	Then the there should be a Test Cycle registered with
		| setting     | value                  |
		| name        | My test cycle          |
		| description | This is my description |
		| iteration   | Iteration 1            |
		| folder      | /TestCycleFolder1      |
		| version     | 1.2.3                  |
    #TODO: find a way to set these
	#And the test run should contain the following test results
	#	| test case ID      | iteration   | version |
	#	| [id-of-test-case] | Iteration 1 | 1.2.3   |

@tc:824
Scenario: Test Result settings are specified
	Given there is a remote server project prepared for publishing test results
	And there is a feature file that was already synchronized before
		"""
		Feature: Sample feature
		
		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And there is a test result file with
		| name           | className                      | outcome |
		| SampleScenario | MyProject.SampleFeatureFeature | Passed  |
	And the synchronizer is configured as
		| setting                                           | value              |
		| publishTestResults/testResultSettings/comment     | This is my comment |
		| publishTestResults/testResultSettings/environment | Env1               |
	When the test result is published successfully
	Then the there should be a test run registered with test results
		| test case ID      | environment | comment            |
		| [id-of-test-case] | Env1        | This is my comment |
