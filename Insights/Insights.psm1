$RestAPIVersion = "2014-04-01";

function Get-AzureQuotaUsage
{
	param
	(
		[string]$SubscriptionId = $Global:AzureSubscription.subscriptionId,
		[ValidateSet('Microsoft.Compute','Microsoft.Network','Microsoft.Storage')] 
		[string]$Provider,
		[string]$Location,
		[string]$apiVersion,
		[switch]$AsJson
	)

	try
	{
		$ErrorActionPreference = 'Stop';
		$Error.Clear();

		$Method = 'GET';
		if (!($apiVersion))
		{
			$apiVersion = $RestAPIVersion;
		}

		$Uri = "https://management.azure.com/subscriptions/$($SubscriptionId)/providers/$($Provider)/locations/$($Location)/usages?api-version=$($apiVersion)";
		
		if ($AsJson)
		{
			Invoke-AzureRestAPI -Method $Method -apiVersion $apiVersion -AuthenticationResult $Global:AzureAuthenticationResult -Uri $Uri |ConvertTo-Json;
		}
		else
		{
			Invoke-AzureRestAPI -Method $Method -apiVersion $apiVersion -AuthenticationResult $Global:AzureAuthenticationResult -Uri $Uri;
		}
	}
	catch
	{
		throw $Error;
	}
}
function Get-AzureEvent
{
	param
	(
		[string]$SubscriptionId = $Global:AzureSubscription.subscriptionId,
		[datetime]$StartDate = (Get-Date).AddDays(-90),
		[datetime]$EndDate = (Get-Date),
		[string]$ResourceGroupName,
		[string]$apiVersion,
		[switch]$AsJson
	)

	try
	{
		$ErrorActionPreference = 'Stop';
		$Error.Clear();

		$Method = 'GET';
		if (!($apiVersion))
		{
			$apiVersion = $RestAPIVersion;
		}

		#
		# TODO
		#
		# Check if StartDate and EndDate are older than 90 days
		#
		# throw error
		#
		$Start = $StartDate.ToUniversalTime().ToString("yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'fff'Z'");
		$End = $EndDate.ToUniversalTime().ToString("yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'fff'Z'");
		
		$EventTimestamp = "eventTimestamp ge '$($Start)' and eventTimestamp le '$($End)'";
		$Filter = "$($EventTimestamp) and eventChannels eq 'Admin, Operation'";
		if ($ResourceGroupName)
		{
			$Filter = "$($Filter) and resourceGroupName eq '$($ResourceGroupName)'"
		}
		
		$Uri = "https://management.azure.com/subscriptions/$($SubscriptionId)/providers/microsoft.insights/eventtypes/management/values?api-version=$($apiVersion)&`$filter=$($Filter)";
		
		if ($AsJson)
		{
			Invoke-AzureRestAPI -Method $Method -apiVersion $apiVersion -AuthenticationResult $Global:AzureAuthenticationResult -Uri $Uri |ConvertTo-Json;
		}
		else
		{
			Invoke-AzureRestAPI -Method $Method -apiVersion $apiVersion -AuthenticationResult $Global:AzureAuthenticationResult -Uri $Uri;
		}
	}
	catch
	{
		throw $Error;
	}
}
function Get-AzureAlertRule
{
	param
	(
		[string]$SubscriptionId = $Global:AzureSubscription.subscriptionId,
		[string]$ResourceGroupName,
		[string]$RuleName,
		[string]$apiVersion,
		[switch]$AsJson
	)

	try
	{
		$ErrorActionPreference = 'Stop';
		$Error.Clear();

		$Method = 'GET';
		if (!($apiVersion))
		{
			$apiVersion = $RestAPIVersion;
		}

		$Uri = "https://management.azure.com/subscriptions/$($SubscriptionId)";
		if ($ResourceGroupName)
		{
			$Uri = "$($uri)/resourceGroups/$($ResourceGroupName)";
		}
		$Uri = "$($Uri)/providers/microsoft.insights/alertRules";
		if ($RuleName)
		{
			$Uri = "$($uri)/$($RuleName)";
		}
		$Uri = "$($Uri)?api-version=$($apiVersion)";

		if ($AsJson)
		{
			Invoke-AzureRestAPI -Method $Method -apiVersion $apiVersion -AuthenticationResult $Global:AzureAuthenticationResult -Uri $Uri |ConvertTo-Json;
		}
		else
		{
			Invoke-AzureRestAPI -Method $Method -apiVersion $apiVersion -AuthenticationResult $Global:AzureAuthenticationResult -Uri $Uri;
		}
	}
	catch
	{
		throw $Error;
	}
}

function New-AzureAlert
{
	param
	(
		[parameter(Mandatory=$true)]
		[string]$ResourceGroupName,
		[parameter(Mandatory=$true)]
		[string]$Location,
		[parameter(Mandatory=$false)]
		[hashtable[]]$Tags,
		[parameter(Mandatory=$true)]
		[string]$Name,
		[parameter(Mandatory=$false)]
		[string]$Description,
		[parameter(Mandatory=$true)]
		[boolean]$IsEnabled,
		[parameter(Mandatory=$true)]
		[string]$ResourceUri,
		[parameter(Mandatory=$true)]
		[string]$MetricName,
		[parameter(Mandatory=$true)]
		[int]$Threshold,
		[parameter(Mandatory=$true)]
		[int]$WindowSize,
		[parameter(Mandatory=$true)]
		[validateset('average','count','last','minimum','maximum','total')]
		[string]$TimeAggregation,
		[parameter(Mandatory=$true)]
		[boolean]$SendToServiceOwners,
		[parameter(Mandatory=$false)]
		[string[]]$CustomEmails,
		[parameter(Mandatory=$false)]
		[string]$SubscriptionId = $Global:AzureSubscription.subscriptionId,
		[parameter(Mandatory=$false)]
		[string]$apiVersion,
		[parameter(Mandatory=$false)]
		[switch]$AsJson
	)

	try
	{
		$ErrorActionPreference = 'Stop';
		$Error.Clear();

		$Method = 'PUT';
		if (!($apiVersion))
		{
			$apiVersion = $RestAPIVersion;
		}

		$Uri = "https://management.azure.com/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/providers/microsoft.insights/alertRules/$($Name)?api-version=$($apiVersion)";
		$PayLoad = New-JsonAlert -Location $Location -Tags $Tags -Name $Name -Description $Description -IsEnabled $IsEnabled -ResourceUri $ResourceUri -MetricName $MetricName -Threshold $Threshold -WindowSize $WindowSize -TimeAggregation $TimeAggregation -SendToServiceOwners $SendToServiceOwners -CustomEmails $CustomEmails |ConvertTo-Json -Depth 4;

		if ($AsJson)
		{
			Invoke-AzureRestAPI -Method $Method -apiVersion $apiVersion -AuthenticationResult $Global:AzureAuthenticationResult -Uri $Uri -Payload $Payload |ConvertTo-Json;
		}
		else
		{
			Invoke-AzureRestAPI -Method $Method -apiVersion $apiVersion -AuthenticationResult $Global:AzureAuthenticationResult -Uri $Uri -Payload $Payload;
		}
	}
	catch
	{
		throw $Error;
	}
}

function New-JsonAlert
{
	param
	(
		[parameter(Mandatory=$true)]
		[string]$Location,
		[parameter(Mandatory=$false)]
		[hashtable[]]$Tags,
		[parameter(Mandatory=$true)]
		[string]$Name,
		[parameter(Mandatory=$false)]
		[string]$Description,
		[parameter(Mandatory=$true)]
		[boolean]$IsEnabled,
		[parameter(Mandatory=$true)]
		[string]$ResourceUri,
		[parameter(Mandatory=$true)]
		[string]$MetricName,
		[parameter(Mandatory=$true)]
		[int]$Threshold,
		[parameter(Mandatory=$true)]
		[int]$WindowSize,
		[parameter(Mandatory=$true)]
		[validateset('average','count','last','minimum','maximum','total')]
		[string]$TimeAggregation,
		[parameter(Mandatory=$true)]
		[boolean]$SendToServiceOwners,
		[parameter(Mandatory=$false)]
		[string[]]$CustomEmails
	)

	$DataSource = New-DataSource -ResourceUri $ResourceUri -MetricName $MetricName
	$Condition = New-Condition -Datasource $DataSource -Threshold $Threshold -WindowSize $WindowSize -TimeAggregation $TimeAggregation 
	$Action = New-Action -SendToServiceOwners $SendToServiceOwners -CustomEmails $CustomEmails

	$Properties = New-Object -TypeName psobject -Property @{
		'name' = $Name
		'description' = $Description
		'isEnabled' = $IsEnabled
		'condition' = $Condition
		'action' = $Action
	} |Select-Object -Property name, description, isEnabled, condition, action
	New-Object -TypeName psobject -Property @{
		'location' = $Location
		'tags' = $Tags
		'properties' = $Properties
	} |Select-Object -Property location, tags, properties
}

function New-DataSource
{
	param
	(
		[parameter(Mandatory=$false)]
		[string]$Type = 'Microsoft.Azure.Management.Insights.Models.RuleMetricDataSource',
		[parameter(Mandatory=$true)]
		[string]$ResourceUri,
		[parameter(Mandatory=$true)]
		[string]$MetricName
	)
	New-Object -TypeName psobject -Property @{
		'odata.type' = $Type
		'resourceUri' = $ResourceUri
		'metricName' = $TimeAggregation
	} |Select-Object -Property 'odata.type','resourceUri','metricName'
}
function New-Condition
{
	param
	(
		[parameter(Mandatory=$false)]
		[string]$Type = 'Microsoft.Azure.Management.Insights.Models.ThresholdRuleCondition',
		[parameter(Mandatory=$true)]
		[object]$Datasource,
		[parameter(Mandatory=$true)]
		[int]$Threshold,
		[parameter(Mandatory=$true)]
		[validateset(5,10,15,30,45,60)]
		[int]$WindowSize,
		[parameter(Mandatory=$true)]
		[validateset('average','count','last','minimum','maximum','total')]
		[string]$TimeAggregation
	)
	New-Object -TypeName psobject -Property @{
		'odata.type' = $Type
		'datasource' = $DataSource
		'threshold' = $Threshold
		'windowSize' = "PT$($WindowSize)M"
		'timeAggregation' = $TimeAggregation
	} |Select-Object -Property 'odata.type','datasource','threshold','windowSize','timeAggregation'
}
function New-Action
{
	param
	(
		[parameter(Mandatory=$false)]
		[string]$Type = 'Microsoft.Azure.Management.Insights.Models.RuleEmailAction',
		[parameter(Mandatory=$true)]
		[boolean]$SendToServiceOwners,
		[parameter(Mandatory=$false)]
		[string[]]$CustomEmails
	)
	New-Object -TypeName psobject -Property @{
		'odata.type' = $Type
		'sendToServiceOwners' = $SendToServiceOwners
		'customEmails' = $CustomEmails
	} |Select-Object -Property 'odata.type','sendToServiceOwners','customEmails'
}