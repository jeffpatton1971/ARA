function Get-AzureResourceProvider
{
	param
	(
		[string]$SubscriptionId = $Global:AzureSubscription.subscriptionId,
		[string]$Namespace
	)

	try
	{
		$ErrorActionPreference = 'Stop';
		$Error.Clear();

		$Method = 'GET';
		$apiVersion = '2015-01-01';

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