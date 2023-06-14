@customization @feature:1081
Feature: Do not synchronize title

Rule: The title of the Test Case should not be changed

@tc:1092
Scenario: Update scenario that is synchronized to a Test Case with custom title
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                      | value |
		| customizations/doNotSynchronizeTitle/enabled | true  |
	And there is a new Test Case as
		| field | value        |
		| title | Custom title |
	And there is a scenario in the local repository
		"""
		@tc:[id-of-test-case]
		Scenario: Updated sample scenario
			When I do something
		"""
	When the local repository is synchronized with push
	Then the Test Case title should be still "Custom title"

@tc:1093
@diag:hash
Scenario: Only the scenario title is updated
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                      | value |
		| customizations/doNotSynchronizeTitle/enabled | true  |
	And there is a new Test Case as
		| field | value        |
		| title | Custom title |
	And there is a scenario that was updated and synchronized as
		"""
		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	When the scenario is updated and synchronized to
		"""
		@tc:[id-of-test-case]
		Scenario: Updated sample scenario
			When I do something
		"""
	Then the scenario should have been up-to-date

@tc:1094
@diag:hash
Scenario: Use another field to capture scenario title
	In this scenario, only the title change, but this still triggers the synchronization because it is used in field updates.
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                                | value                     |
		| customizations/doNotSynchronizeTitle/enabled           | true                      |
		| synchronization/fieldUpdates/[description-field]/value | Scenario: {scenario-name} |
	And there is a new Test Case as
		| field | value        |
		| title | Custom title |
	And there is a scenario that was updated and synchronized as
		"""
		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	When the scenario is updated and synchronized to
		"""
		@tc:[id-of-test-case]
		Scenario: Updated sample scenario
			When I do something
		"""
	Then the Test Case title should be still "Custom title"
	And the test case fields are set to the following values
		| field identifier    | value                             |
		| [description-field] | Scenario: Updated sample scenario |



Rule: The title should be set initially, but can be customized

@tc:1095
Scenario: The title is set initially
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                      | value |
		| customizations/doNotSynchronizeTitle/enabled | true  |
	And there is a scenario in the local repository
		"""
		Scenario: Sample scenario
			When I do something
		"""
	When the local repository is synchronized with push
	Then a new Test Case work item "Scenario: Sample scenario" is created in Azure DevOps

@tc:1096
Scenario: The inital title is customized
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                          | value        |
		| customizations/doNotSynchronizeTitle/enabled     | true         |
		| synchronization/fieldUpdates/System.Title/value  | Custom title |
		| synchronization/fieldUpdates/System.Title/update | onCreate     |
	And there is a scenario in the local repository
		"""
		Scenario: Sample scenario
			When I do something
		"""
	When the local repository is synchronized with push
	Then a new Test Case work item "Custom title" is created in Azure DevOps

Rule: Test Case changes can be pulled

@tc:1097
@adoSpecific @pull
Scenario: Create scenario from new Test Case
	Given there is an Azure DevOps project with an empty test suite 'MySuite'
	And the synchronizer is configured to enable back syncing
	And the synchronizer is configured to add test cases to test suite 'MySuite'
	And the synchronizer is configured to create local scenarios for new test cases
	And the synchronizer is configured as
		| setting                                      | value |
		| customizations/doNotSynchronizeTitle/enabled | true  |
	And there is a new Test Case in Suite 'MySuite' as
		| field | value                     |
		| title | Scenario: Sample scenario |
		| steps | When I do something       |
	When the SpecSync pull is executed
	Then the local workspace contains a feature file '[id-of-test-case].feature' as
		"""
		Feature: [id-of-test-case]

		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And the feature file is added to the project

@tc:1098
@pull
Scenario: Title changes are not pulled
	Given there is an Azure DevOps project
	And the synchronizer is configured to enable back syncing
	And the synchronizer is configured as
		| setting                                      | value |
		| customizations/doNotSynchronizeTitle/enabled | true  |
	And there is a feature file in the local workspace that was not synchronized yet
		"""
		Feature: Sample feature

		Scenario: Sample scenario
			When I do something
		"""
	And the feature file has been synchronized already
	When the Test Case title is updated to 'Custom title'
	And the Test Case steps are updated to 
		| keyword | text                  |
		| When    | I really do something |
	And the SpecSync pull is executed
	Then the feature file in the local workspace should have been updated to
		"""
		Feature: Sample feature

		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I really do something
		"""
