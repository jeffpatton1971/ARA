$RestAPIVersion = "2015-07-01-preview";

function Get-AzureSupportTicket
{
	param
	(
		[string]$SubscriptionId = $Global:AzureSubscription.subscriptionId,
		[string]$TicketId,
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

		$Uri = "https://management.azure.com/subscriptions/$($SubscriptionId)/providers/Microsoft.Support/supportTickets";
		if ($TicketId)
		{
			$Uri = "$($Uri)/$($TicketId)";
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