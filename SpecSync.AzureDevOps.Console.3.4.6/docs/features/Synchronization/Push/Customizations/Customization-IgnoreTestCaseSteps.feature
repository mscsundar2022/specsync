﻿@customization @notsupported-JIRA.DataCenter.ZephyrScale
Feature: Ignore TestCase steps

@tc:178
Scenario: Ignores prefixed steps when updating test case
	Given there is a VSTS project
	And the synchronizer is configured to skip test case steps starting with 
         | prefix |
         | SKIP   |       
	And there is a new Test Case as
		| field | value                                                         |
		| title | Scenario: Sample scenario                                     |
		| steps | SKIP this step; Given there is something; When I do something |
	And there is a scenario in the local workspace
		"""
		@tc:[id-of-test-case]
		Scenario: Updated sample scenario
			When I do something new
			Then something will change
		"""
	When the local workspace is synchronized with push
	Then the Test Case title is updated to "Scenario: Updated sample scenario"
	And the test case contains the following test steps
		| step                       |
		| SKIP this step             |
		| When I do something new    |
		| Then something will change |

@tc:179
Scenario: Should only ignore leading steps
	Given there is a VSTS project
	And the synchronizer is configured to skip test case steps starting with 
         | prefix |
         | SKIP   |       
	And there is a new Test Case as
		| field | value                                                         |
		| title | Scenario: Sample scenario                                     |
		| steps | Given there is something; SKIP this step; When I do something |
	And there is a scenario in the local workspace
		"""
		@tc:[id-of-test-case]
		Scenario: Updated sample scenario
			When I do something new
			Then something will change
		"""
	When the local workspace is synchronized with push
	Then the Test Case title is updated to "Scenario: Updated sample scenario"
	And the test case contains the following test steps
		| step                       |
		| When I do something new    |
		| Then something will change |

@tc:180
Scenario: Do not update scenario if not changed, even if there are ignored steps
	Given there is a VSTS project
	And the synchronizer is configured to skip test case steps starting with 
         | prefix |
		 | SKIP   |
	And there is a scenario in the local workspace
		"""
		Scenario: Sample scenario
			Given there is something
			When I do something
		"""
	And the feature file has been synchronized already
	When the Test Case steps are updated to 
		| keyword | text               |
		|         | SKIP this step     |
		| Given   | there is something |
		| When    | I do something     |
	When the local workspace is synchronized with push
	Then the Test Case should not be changed
	And the log should not contain "CONFLICT"

@tc:181
Scenario: Pull does not add ignored steps to the feature
	Given there is a VSTS project
	And the synchronizer is configured to enable back syncing
	And the synchronizer is configured to skip test case steps starting with 
         | prefix |
		 | SKIP   |
	And there is a scenario in the local workspace
		"""
		Scenario: Sample scenario
			Given there is something
			When I do something
		"""
	And the feature file has been synchronized already
	When the Test Case steps are updated to 
		| keyword | text                       |
		|         | SKIP this step             |
		| Given   | there is something changed |
		| When    | I do something             |
	And the SpecSync pull is executed
	Then the feature file in the local workspace should have been updated to
		"""
		Feature: Sample feature
		@tc:[id-of-test-case]
		Scenario: Sample scenario
			Given there is something changed
			When I do something
		"""	