$RestAPIVersion = "2015-01-01";

function Get-AzureResourceProvider
{
	param
	(
		[string]$SubscriptionId = $Global:AzureSubscription.subscriptionId,
		[string]$Namespace,
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

		$Uri = "https://management.azure.com/subscriptions/$($SubscriptionId)/providers";

		if ($Namespace)
		{
			$Uri = "$($Uri)/$($Namespace)";
		}

		$Uri = "$($Uri)?api-version=$($apiVersion)";
		
		Invoke-AzureRestAPI -Method $Method -apiVersion $apiVersion -AuthenticationResult $Global:AzureAuthenticationResult -Uri $Uri;
	}
	catch
	{
		throw $Error;
	}
}
function Get-AzureResourceHealth
{
	param
	(
		[string]$SubscriptionId = $Global:AzureSubscription.subscriptionId,
		[ValidateSet('Microsoft.Compute','Microsoft.Network','Microsoft.Storage')] 
		[string]$Provider,
		[string]$ResourceGroupName,
		[string]$ResourceType,
		[string]$ResourceName,
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
		$Uri = "https://management.azure.com/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/providers/$($Provider)/$($ResourceType)/$($ResourceName)/providers/Microsoft.ResourceHealth/availabilityStatuses?api-version=$($apiVersion)";
		
		Invoke-AzureRestAPI -Method $Method -apiVersion $apiVersion -AuthenticationResult $Global:AzureAuthenticationResult -Uri $Uri;
	}
	catch
	{
		throw $Error;
	}
}