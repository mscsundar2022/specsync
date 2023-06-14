@bypass-ado-integration
Feature: Tag expressions

@tc:186
Scenario Outline: Tag expression syntax
	Given Scenario "Green" has tags "<matching tags>"
	And Scenario "Red" has tags "<non-matching tags>"
	When the tag expression "<tag expression>" is evaluated for the scenarios
	Then Scenario "Green" should match
	And Scenario "Red" should not match
Examples: 
	| description          | tag expression            | matching tags        | non-matching tags |
	| contains tag         | @finished                 | @foo @finished @bar  | @foo @bar         |
	| empty does not match | @finished                 | @finished            |                   |
	| and                  | @finished and @automated  | @automated @finished | @finished         |
	| or                   | @finished or @automated   | @finished            |                   |
	| not                  | not @finished             | @foo                 | @finished         |
	| parenthesis          | not (@manual or @ignored) | @foo                 | @ignored          |
	| tail wildcard        | @bug:*                    | @bug:123             |                   |

Rule: Filter, scope and other conditions should be satisfied if there at least one scenario outline examples that satisfies the condition

This is a special evaluation for scenario outlines. For scenarios the tags of the 
scenario are evaluated.

Breaking changes bacause of the scenario outline examples evaluation logic:
- tag filter
  - low: We synchronize scenarios that only has the tag on Examples
  - reaction: use more specific tags for filter
- tag scope
  - medium: We synchronize scenarios that have the tag only on Examples
  - reaction: add a @noSync tag to the scenario outline and add an "... and not @noSync" to the tag scope
- reset state condition
  - low: resets state if the tag is only in examples
  - reaction: do not use condition tags for examples
- state condition
  - low: resets state if the tag is only in examples
  - reaction: do not use condition tags for examples
- automation condition
  - low: marks tests as automated if they have the conditioned tag in examples
  - reaction: do not use condition tags for examples
- field update condition(s)
  - low: new feature

@tc:937
Scenario Outline: Sceanrio outline examples tags are considered
	Given a scenario outline with tags "@on_scenario" with examples:
		| name       | tags          |
		| Examples 1 | @tag1         |
		| Examples 2 | @tag2a @tag2b |
	When the tag expression "<tag expression>" is evaluated for the scenarios
	Then the scenario outline should <match?>
Examples: 
	| description                            | tag expression         | match?    | result without considerign examples block tags |
	| on one examples block only             | @tag1                  | match     | not match                                      |
	| negative for one examples block        | not @tag1              | match     | match                                          |
	| tags on different examples blocks      | @tag1 and @tag2a       | not match | not match                                      |
	| multiple tags on an examples block     | @tag2a and @tag2b      | match     | not match                                      |
	| mixed examples block and scenario tags | @on_scenario and @tag1 | match     | not match                                      |
