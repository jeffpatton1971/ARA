$RestAPIVersion = "2014-04-01";

function Get-AzureQuotaUsage
{
	param
	(
		[string]$SubscriptionId = $Global:AzureSubscription.subscriptionId,
		[ValidateSet('Microsoft.Compute','Microsoft.Network','Microsoft.Storage')] 
		[string]$Provider,
		[string]$Location,
		[string]$apiVersion
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
		
		Invoke-AzureRestAPI -Method $Method -apiVersion $apiVersion -AuthenticationResult $Global:AzureAuthenticationResult -Uri $Uri;
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
		[string]$apiVersion
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
		
		Invoke-AzureRestAPI -Method $Method -apiVersion $apiVersion -AuthenticationResult $Global:AzureAuthenticationResult -Uri $Uri;
	}
	catch
	{
		throw $Error;
	}
}