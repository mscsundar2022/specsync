@config-init @feature:1040
Feature: Initialize Configuration

Rule: A basic configuration can be initialized for Azure DevOps

@tc:1041
@adoSpecific
Scenario: A basic configuration is initialized for Azure DevOps 
	Given there is an Azure DevOps project
	When SpecSync init is executed with answers successfully:
		| question                                              | answer               | optional |
		| Azure DevOps project URL                              | [remote-project-url] | false    |
		| Do you want to check connection?                      | yes                  | false    |
		| Azure DevOps personal access token (PAT) or user name | [remote-user-name]   | false    |
		| Password for user '[remote-user-name]'                | [remote-password]    | true     |
		| Is this ok?                                           | yes                  | false    |
	Then the configuration file should have been updated with
		| setting           | value                |
		| remote/projectUrl | [remote-project-url] |

@tc:1042
@bypass-ado-integration
Scenario: Authenticating with PAT
	Given there is an Azure DevOps project
	When SpecSync init is executed with answers successfully:
		| question                                              | answer               | 
		| Azure DevOps project URL                              | [remote-project-url] | 
		| Do you want to check connection?                      | yes                  | 
		| Azure DevOps personal access token (PAT) or user name | [remote-pat]         | 
	Then the configuration file should have been updated with
		| setting           | value                |
		| remote/projectUrl | [remote-project-url] |

@tc:1043
@bypass-ado-integration
Scenario Outline: Authenticating with credentials from user-specific config file
	Given there is an Azure DevOps project
	And there is a user-specific config file with the following content:
		"""
		{
			"knownRemotes": [
				{
					"projectUrl": "[remote-project-url]",
					"user": "<user name>"
				}
			]
		}
		"""
	When SpecSync init is executed with answers successfully:
		| question                         | answer               | optional |
		| Azure DevOps project URL         | [remote-project-url] | false    |
		| Do you want to check connection? | yes                  | false    |
		| Password for user '<user name>'  | [remote-password]    | true     |
	Then the configuration file should have been updated with
		| setting           | value                |
		| remote/projectUrl | [remote-project-url] |
Examples: 
	| description   | user name          |
	| Use PAT       | [remote-pat]       |
	| Use User Name | [remote-user-name] |

@tc:1044
@bypass-ado-integration
Scenario: Offers saving credentials to user-specific config file
	Given there is an Azure DevOps project
	When SpecSync init is executed with answers successfully:
		| question                                              | answer               |
		| Azure DevOps project URL                              | [remote-project-url] |
		| Do you want to check connection?                      | yes                  |
		| Azure DevOps personal access token (PAT) or user name | [remote-pat]         |
		| Do you want to save the PAT to the user-config file   | yes                  |
	Then the configuration file should have been updated with
		| setting           | value                |
		| remote/projectUrl | [remote-project-url] |
	And the user-specific configuration file should have been updated with
		| setting                   | value                |
		| knownRemotes[]/projectUrl | [remote-project-url] |
		| knownRemotes[^1]/user     | [remote-pat]         |

Rule: Asks to override configuration file if it already exists

@tc:1045
@bypass-ado-integration
Scenario: The configuration file already exists
	Given there is an Azure DevOps project
	And there is a file specsync.json
	When SpecSync init is executed with answers:
		| question                           | answer   | optional |
		| Do you want to overwrite the file? | <answer> | false    |
	Then the command should have been cancelled
	And the configuration file should not change
Examples: 
	| description       | answer |
	| no override       | no     |
	| the default is no |        |

Rule: Cancelled when the connection check fails

@tc:1046
@bypass-ado-integration
Scenario: Wrong credentials provided
	Given there is an Azure DevOps project
	When SpecSync init is executed with answers:
		| question                                              | answer               | optional |
		| Azure DevOps project URL                              | [remote-project-url] | false    |
		| Azure DevOps personal access token (PAT) or user name | wrong-user           | false    |
		| Password for user 'wrong-user'                        | wrong-password       | true     |
	Then the command should finish with errors
	And the configuration file should not change


Rule: There are useful defaults for the questions

@tc:1047
@bypass-ado-integration
Scenario: Using default answers for the questions
	Given there is an Azure DevOps project
	When SpecSync init is executed with answers successfully:
		| question                                              | answer               | optional |
		| Azure DevOps project URL                              | [remote-project-url] | false    |
		| Azure DevOps personal access token (PAT) or user name | [remote-user-name]   | false    |
		| Password for user '[remote-user-name]'                | [remote-password]    | true     |
	Then the configuration file should have been updated with
		| setting           | value                |
		| remote/projectUrl | [remote-project-url] |
