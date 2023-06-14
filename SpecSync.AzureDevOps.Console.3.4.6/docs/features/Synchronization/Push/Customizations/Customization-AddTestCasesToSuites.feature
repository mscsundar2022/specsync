@customization @adoSpecific
Feature: Add Test Cases to Suites

Rule: Add the syncrhonized Test Cases to a configured Suite

@tc:1006
Scenario: Linked test cases are added to the Test Suite
	Given there is an Azure DevOps project with an empty test suite 'Custom Suite 1'
	And there is a feature file in the local repository
		"""
		Feature: My Feature
		Scenario: Scenario 1
			When I do something
		Scenario: Scenario 2
			When I do something
		Scenario: Scenario 3
			When I do something
		"""
	And the synchronizer is configured as
		| setting                                                | value          |
		| customizations/addTestCasesToSuites/enabled            | true           |
		| customizations/addTestCasesToSuites/testSuites[0]/name | Custom Suite 1 |
	When the local repository is synchronized with push
	Then the command should succeed
	And the Test Suite should contain the following Test Cases
		| test case            |
		| Scenario: Scenario 1 |
		| Scenario: Scenario 2 |
		| Scenario: Scenario 3 |

@tc:1007
@bypass-ado-integration
Scenario: Test Cases are added to multiple Test Suites
	Given there is an Azure DevOps project
	And there is an empty test suite 'Custom Suite 1' in the project
	And there is an empty test suite 'Custom Suite 2' in the project
	And there is a feature file in the local repository
		"""
		Feature: My Feature
		Scenario: Scenario 1
			When I do something
		"""
	And the synchronizer is configured as
		| setting                                                | value          |
		| customizations/addTestCasesToSuites/enabled            | true           |
		| customizations/addTestCasesToSuites/testSuites[0]/name | Custom Suite 1 |
		| customizations/addTestCasesToSuites/testSuites[1]/name | Custom Suite 2 |
	When the local repository is synchronized with push
	Then the command should succeed
	And the Test Suite 'Custom Suite 1' should contain the following Test Cases
		| test case            |
		| Scenario: Scenario 1 |
	And the Test Suite 'Custom Suite 2' should contain the following Test Cases
		| test case            |
		| Scenario: Scenario 1 |


Rule: Restrict Test Cases to be added to the Suite by local test case conditions

@tc:1008
@bypass-ado-integration
Scenario: Some scenarios are added to a Suite based on a condition
	Given there is an Azure DevOps project with an empty test suite 'Custom Suite 1'
	And there is a feature file in the local repository
		"""
		Feature: My Feature
		@mytag
		Scenario: Scenario 1
			When I do something
		@mytag @othertag
		Scenario: Scenario 2
			When I do something
		Scenario: Scenario 3
			When I do something
		"""
	And the synchronizer is configured as
		| setting                                                     | value                    |
		| customizations/addTestCasesToSuites/enabled                 | true                     |
		| customizations/addTestCasesToSuites/testSuites[0]/name      | Custom Suite 1           |
		| customizations/addTestCasesToSuites/testSuites[0]/condition | @mytag and not @othertag |
	When the local repository is synchronized with push
	Then the command should succeed
	And the Test Suite should contain the following Test Cases
		| test case            |
		| Scenario: Scenario 1 |


Rule: The removed scenarios (if detected) should be removed from the suite

@tc:1009
Scenario: The Test Case of a deleted scenario is removed from the Test Suite if a Test Suite Scope was configured
	Given there is an Azure DevOps project with an empty test suite 'MySuite'
	And there is an empty test suite 'Custom Suite 1' in the project
	And the synchronizer is configured to add test cases to test suite 'MySuite'
	And the synchronizer is configured as
		| setting                                                | value          |
		| customizations/addTestCasesToSuites/enabled            | true           |
		| customizations/addTestCasesToSuites/testSuites[0]/name | Custom Suite 1 |
	And there is a feature file that was already synchronized before
		"""
		Feature: My Feature

		@tc:[id-of-test-case]
		Scenario: Scenario 1
			When I do something
		"""
	When the feature file is updated to
		"""
		Feature: My Feature

		# Scenario 1 deleted
		"""
	And the local repository is synchronized with push
	Then the Test Suite 'Custom Suite 1' should be empty
