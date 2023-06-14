@bypass-ado-integration
Feature: Use custom Test Case tag prefix and tag prefix separator

By default, SpecSync uses processes link tags in @<prefix>:<id> format. 

For Test Case links, the default prefix is "tc", but that can be customized.

The tag prefix separator (':' by default) can be also customized to support tags 
for examle in @story=123 format.

Rule: The default "tc" Test Case link tag prefix can be changed

@tc:776
Scenario: A custom Test Case link tag prefix is used
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                           | value    |
		| synchronization/testCaseTagPrefix | TestCase |
	And there is an updated scenario that has been synchronized before
		"""
		@TestCase:[id-of-test-case]
		Scenario: Updated sample scenario
			When I do something
		"""
	When the local repository is synchronized with push
	Then the Test Case title is updated to "Scenario: Updated sample scenario"

Rule: Custom tag prefix separator can be speicified

@tc:777
Scenario: Link tags use equal style
	Given there is an Azure DevOps project with a Bug
	And the synchronizer is configured as
		| setting                                | value |
		| synchronization/tagPrefixSeparators[0] | =     |
		| synchronization/links[]/tagPrefix      | bug   |
	And a @bug tag has been added to an existing synchronized scenario as:
		"""
		@tc=[id-of-test-case] @bug=[id-of-bug]
		Scenario: Sample scenario
			When I do something
		"""
	When the local workspace is synchronized with push
	Then the Test Case should be linked to the Bug

@tc:778
Scenario: Link tags use mixed prefixes
	Given there is an Azure DevOps project with a Bug
	And the synchronizer is configured as
		| setting                                | value |
		| synchronization/tagPrefixSeparators[0] | =     |
		| synchronization/tagPrefixSeparators[1] | :     |
		| synchronization/links[]/tagPrefix      | bug   |
	And a @bug tag has been added to an existing synchronized scenario as:
		"""
		@tc=[id-of-test-case] @bug:[id-of-bug]
		Scenario: Sample scenario
			When I do something
		"""
	When the local workspace is synchronized with push
	Then the Test Case should be linked to the Bug


@tc:779
Scenario: The primary tag prefix separator is used for creating link tags
	Given there is an Azure DevOps project with a Bug
	And the synchronizer is configured as
		| setting                                | value |
		| synchronization/tagPrefixSeparators[0] | =     |
		| synchronization/tagPrefixSeparators[1] | :     |
		| synchronization/links[]/tagPrefix      | bug   |
	And there is a scenario in the local repository
		"""
		@bug:[id-of-bug]
		Scenario: Sample scenario
			When I do something
		"""
	When the local repository is synchronized with push
	Then a new Test Case work item "Scenario: Sample scenario" is created in Azure DevOps
	And the Test Case should be linked to the Bug
	And a tag "@tc=[id-of-new-test-case]" is added to the scenario in the local repository
