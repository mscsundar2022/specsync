@bypass-ado-integration
Feature: Conditional field updates

Rule: Can set a field to a fixed value

@tc:782
Scenario: A scenario field is updated
	Given there is an Azure DevOps project
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And the synchronizer is configured as
		| setting                                   | value |
		| synchronization/fieldUpdates/System.State | Ready |
	When SpecSync push is executed
	Then the Test Case state should be 'Ready' 

Rule: Can set the field value when a particular condition (tag expression) is satisfied

@tc:783
Scenario Outline: The scenario gets a tag that triggers a field update
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                             | value        |
		| synchronization/fieldUpdates/System.State/value     | Design       |
		| synchronization/fieldUpdates/System.State/condition | @designState |
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And the Test Case state is set to 'Ready'
	When the scenario is updated to
		"""
		@tc:[id-of-test-case] <updated tag>
		Scenario: Sample scenario
			When I do something
		"""
	And SpecSync push is executed
	Then the Test Case state should be '<result>' 
Examples: 
	| description                        | updated tag  | result |
	| the tags match the condition       | @designState | Design |
	| the tags don't match the condition | @other       | Ready  |

Rule: The tags that match to the condition are not added as labels by default

@tc:784	
Scenario Outline: The scenario tags are used in conditions
	Note: removeMatchingTags can only be used for update=always that is the default
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                                      | value                |
		| synchronization/fieldUpdates/System.State/value              | Design               |
		| synchronization/fieldUpdates/System.State/condition          | @designState         |
		| synchronization/fieldUpdates/System.State/removeMatchingTags | <removeMatchingTags> |
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case]
		Scenario: Sample scenario
			When I do something
		"""
	And the Test Case state is set to 'Ready'
	When the scenario is updated to
		"""
		@tc:[id-of-test-case] @designState @other
		Scenario: Updated scenario
			When I do something
		"""
	And SpecSync push is executed
	Then the Test Case state should be 'Design'
	And the Test Case should have the following tags: '<result tags>'
Examples: 
	| description                         | removeMatchingTags | result tags        |
	| removed by default                  |                    | other              |
	| remove forced                       | true               | other              |
	| not removed                         | false              | designState, other |

Rule: For field updates it can be specified when the update should be performed (always, onCreate, onChange)

@tc:785
@diag:SpecSyncConfiguration
Scenario Outline: A scenario field is updated at different events
	Assuming that the default value for state is 'Design'
	Given there is an Azure DevOps project
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case]
		Scenario: Original title
			When I do something
		"""
	And the synchronizer is configured as
		| setting                                          | value  |
		| synchronization/fieldUpdates/System.State/value  | Ready  |
		| synchronization/fieldUpdates/System.State/update | <when> |
	When the scenario is updated to
		"""
		@tc:[id-of-test-case]
		Scenario: <updated title>
			When I do something
		"""
	And SpecSync push is executed
	Then the Test Case state should be '<result>' 
Examples: 
	| description                              | when             | updated title  | result |
	| always update - not changed              | always           | Original title | Ready  |
	| always update - changed                  | always           | Updated title  | Ready  |
	| update on change - not changed           | onChange         | Original title | Design |
	| update on change - changed               | onChange         | Updated title  | Ready  |
	| update on create - not changed           | onCreate         | Original title | Design |
	| update on create - changed               | onCreate         | Updated title  | Design |
	| update on create-or-change - not changed | onCreateOrChange | Original title | Design |
	| update on create-or-change - changed     | onCreateOrChange | Updated title  | Ready  |

@tc:786
Scenario Outline: Field is initialized with different update on settings
	Assuming that the default value for state is 'Design'
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                          | value  |
		| synchronization/fieldUpdates/System.State/value  | Ready  |
		| synchronization/fieldUpdates/System.State/update | <when> |
	And there is a scenario in the local repository
		"""
		Scenario: Sample scenario
			When I do something
		"""
	When the local repository is synchronized with push
	Then a new Test Case work item "Scenario: Sample scenario" is created in Azure DevOps
	And the Test Case state should be '<result>' 
Examples: 
	| description                | when             | result |
	| always update              | always           | Ready  |
	| update on change           | onChange         | Design |
	| update on create           | onCreate         | Ready  |
	| update on create-or-change | onCreateOrChange | Ready  |

Rule: Field can be updated to different values based on condition (switch)

@tc:787
Scenario Outline: A scenario field is updated to different values
	Given there is an Azure DevOps project
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case]
		Scenario: Scenario title
			When I do something
		"""
	And the synchronizer is configured as
		| setting                                                                 | value  |
		| synchronization/fieldUpdates/System.State/conditionalValue/@readyState  | Ready  |
		| synchronization/fieldUpdates/System.State/conditionalValue/@closedState | Closed |
		| synchronization/fieldUpdates/System.State/conditionalValue/otherwise    | Design |
	And the Test Case state is set to '<value before>'
	When the scenario is updated to
		"""
		@tc:[id-of-test-case] <updated tag>
		Scenario: Scenario title
			When I do something
		"""
	And SpecSync push is executed
	Then the Test Case state should be '<result>' 
Examples: 
	| description                                  | value before | updated tag  | result |
	| set based on condition                       | Design       | @readyState  | Ready  |
	| set based on different condition             | Design       | @closedState | Closed |
	| set when no other conditions match otherwise | Ready        | @other       | Design |

Rule: The field can be updated based on suffix of the tag

@tc:788
Scenario Outline: A scenario field is updated to the tag suffix
	Assuming that the default value for state is 'Design'
	Given there is an Azure DevOps project
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case]
		Scenario: Scenario title
			When I do something
		"""
	And the synchronizer is configured as
		| setting                                             | value    |
		| synchronization/fieldUpdates/System.State/condition | @state:* |
		| synchronization/fieldUpdates/System.State/value     | {1}      |
	When the scenario is updated to
		"""
		@tc:[id-of-test-case] <updated tag>
		Scenario: Scenario title
			When I do something
		"""
	And SpecSync push is executed
	Then the Test Case state should be '<result>' 
Examples: 
	| description                | updated tag   | result |
	| set to tag value           | @state:Ready  | Ready  |
	| set to different tag value | @state:Closed | Closed |

@tc:789
Scenario Outline: A scenario field is conditionally updated to tag suffix
	Assuming that the default value for state is 'Design'
	Given there is an Azure DevOps project
	And there is a scenario that was already synchronized before
		"""
		@tc:[id-of-test-case]
		Scenario: Scenario title
			When I do something
		"""
	And the synchronizer is configured as
		| setting                                                                 | value  |
		| synchronization/fieldUpdates/System.State/conditionalValue/@state:*     | {1}    |
		| synchronization/fieldUpdates/System.State/conditionalValue/@designState | Design |
	And the Test Case state is set to '<value before>'
	When the scenario is updated to
		"""
		@tc:[id-of-test-case] <updated tag>
		Scenario: Scenario title
			When I do something
		"""
	And SpecSync push is executed
	Then the Test Case state should be '<result>' 
Examples: 
	| description                               | value before | updated tag   | result |
	| set based on wildcard condition           | Design       | @state:Ready  | Ready  |
	| set based on different wildcard condition | Design       | @state:Closed | Closed |
	| set based on concrete tag                 | Ready        | @designState  | Design |

Rule: Update text can contain placeholders

@tc:790
Scenario Outline: Supports different placeholders
	The full list of placeholders can be found at https://specsolutions.gitbook.io/specsync/features/push-features/customization-update-custom-test-case-fields-on-push#template-placeholders
	Given there is an Azure DevOps project
	And the synchronizer is configured as
		| setting                                          | value         |
		| synchronization/fieldUpdates/[description-field] | <placeholder> |
	And there is a feature file "<feature file path>" in the local workspace
		"""
		Feature: Sample feature
		Feature description
		second line

		Rule: My business rule

		Scenario: Sample scenario
		Scenario description
			When I do something
		"""
	When the local workspace is synchronized with push
	Then a new test case work item "Scenario: Sample scenario" is created in the project
	And the test case fields are set to the following values
		| field identifier    | value   |
		| [description-field] | <value> |
Examples: 
	| placeholder                | value                                 | feature file path |
	| {feature-name}             | Sample feature                        | MyFeature.feature |
	| {feature-description}      | Feature description\nsecond line      | MyFeature.feature |
	| {scenario-name}            | Sample scenario                       | MyFeature.feature |
	| {scenario-description}     | Scenario description                  | MyFeature.feature |
	| {rule-name}                | My business rule                      | MyFeature.feature |
	| {feature-description:HTML} | Feature description<br/>\nsecond line | MyFeature.feature |
Examples: path related
	| placeholder                 | value                      | feature file path          |
	| {feature-file-name}         | MyFeature.feature          | MyFeature.feature          |
	| {feature-file-folder}       |                            | MyFeature.feature          |
	| {feature-file-path}         | MyFeature.feature          | MyFeature.feature          |
	| {feature-file-name}         | MyFeature.feature          | Features\MyFeature.feature |
	| {feature-file-folder}       | Features                   | Features\MyFeature.feature |
	| {feature-file-path}         | Features\MyFeature.feature | Features\MyFeature.feature |
	| {feature-file-path:Unix}    | Features/MyFeature.feature | Features\MyFeature.feature |
	| {feature-file-path:Windows} | Features\MyFeature.feature | Features\MyFeature.feature |
Examples: source related
	| placeholder       | value                                                                                                                                             | feature file path |
	| {scenario-source} | Scenario: Sample scenario\nScenario description\n	When I do something                                                                             | MyFeature.feature |
	| {feature-source}  | Feature: Sample feature\nFeature description\nsecond line\n\nRule: My business rule\n\nScenario: Sample scenario\nScenario description\n	When I do something | MyFeature.feature |
