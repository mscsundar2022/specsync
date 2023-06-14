Feature: Complex Addition
 
Rules for complex addition:
- Is able to calculate the result of 42
- Works with zero
- Commutative

@important
Scenario: Add two positive numbers
	Given I have entered the following numbers
		| number |
		| 29     |
		| 13     |
	When I choose add
	Then the result should be 42

Scenario Outline: Add two numbers (outline)
	Given I have entered <a> into the calculator
	And I have entered <b> into the calculator
	When I choose add
	Then the result should be <result>

Examples: 
	| case          | a  | b  | result |
	| classic       | 50 | 70 | 120    |
	| commutativity | 70 | 50 | 120    |
	| zero          | 0  | 42 | 42     |
	