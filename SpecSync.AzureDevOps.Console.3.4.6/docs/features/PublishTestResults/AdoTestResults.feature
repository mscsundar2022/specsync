@publishTestResults @adoSpecific
Feature: Azure DevOps specific test result publishing details

Background: 
	Given there is a remote server project prepared for publishing test results

Rule: The test run can be connected with an Azure DevOps build

@tc:257
Scenario: Build details are specified
	The synchronized Test Cases should be marked as "automated" otherwise SpecSync provides 
	a warning when the Test Run is associated with a build.
	Given the synchronizer is configured as
		| setting                            | value |
		| synchronization/automation/enabled | true  |
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
	And the publishing is configured with
		| setting       | value                   |
		| buildNumber   | [existing-build-number] |
		| buildPlatform | x86                     |
		| buildFlavor   | Debug                   |
	When the test result is published successfully
	Then the there should be a test run registered with 
		| setting        | value               |
		| Build Id       | [existing-build-id] |
		| Build platform | x86                 |
		| Build flavor   | Debug               |

@tc:656
Scenario: Automated test details are specified for the test results
	Azure DevOps can display a test execution history if the automated test details 
	are specified for the test result. Also the specified AutomatedStorage appears 
	as "Test file" filter in the "Tests" tab of the pipeline result.
	Given the synchronizer is configured as
		| setting                            | value |
		| synchronization/automation/enabled | true  |
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
	And the publishing is configured with
		| setting       | value                   |
		| buildNumber   | [existing-build-number] |
	When the test result is published successfully
	Then the there should be a test run registered with test results
		| test case ID      | outcome | automated storage | automated test type | automated test name                                       |
		| [id-of-test-case] | Passed  | MyAssembly.dll    | SpecFlow            | MyCompany.MyNamespace.SampleFeatureFeature.SampleScenario |

Rule: Test Run is created as Automated if scenarios are sycnhronized as automated Test Cases

@tc:337
Scenario Outline: Test Run automation status is set based on whether scenarios are synchronized to automated test cases
	Given the synchronizer is configured to <synchronize to automated> automation
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
	When the test result is published successfully
	Then the there should be a test run registered with 
		| setting      | value                        |
		| Is Automated | <expected automation status> |
Examples: 
	| description                                                      | synchronize to automated | expected automation status |
	| scenarios are synchronized as automated Test Cases               | enable                   | true                       |
	| scenarios are synchronized as not automated Test Cases (default) | skip                     | false                      |

@tc:338
@notsupported-ado2019 @notsupported-tfs2018
Scenario Outline: Test Run automation status can be overridden (automation mismatch)
	This case might lead to automation mismatch error in older Azure DevOps servers
	Given the synchronizer is configured to <synchronize to automated> automation
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
		| setting                                    | value      |
		| publishTestResults/testRunSettings/runType | <run type> |
	When the test result is published successfully
	Then the there should be a test run registered with 
		| setting      | value                        |
		| Is Automated | <expected automation status> |
Examples: 
	| description                                   | synchronize to automated | run type  | expected automation status |
	| Publish automated Test Cases as Manual        | enable                   | Manual    | false                      |
	| Publish non-automated Test Cases as Automated | skip                     | Automated | true                       |

Rule: The single test configuration is used for publishing if not specified

@tc:376
@notsupported-tfs2017 @notsupported-tfs2018 @notsupported-ado2019
Scenario: Test Configuration is not specified
	Given there is a feature file that was already synchronized before
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
		| setting                                    | value      |
		| publishTestResults/testRunSettings/name    | My run     |
		| publishTestResults/testRunSettings/comment | My comment |
	When the test result is published without specifying a Test Configuration
	Then the command should succeed