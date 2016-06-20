function New-AzureContext
{
	param
	(
		[string]$TenantID,
		[string]$ApplicationID,
		[string]$CallbackUri
	)

	try
	{
		$ErrorActionPreference = 'Stop';
		$Error.Clear();

		$adal = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll";
		[System.Reflection.Assembly]::LoadFrom($adal) |Out-Null;

		[System.Uri]$Uri = New-Object System.Uri($CallbackUri);

		#
		# These values may not be necessary
		#
		# $resourceAppIdURI = "https://management.azure.com/";
		# $Authority = "https://login.microsoftonline.com/$($TenantID)/oauth2/token";
		#

		$resourceAppIdURI = "https://management.core.windows.net/";
		$Authority = "https://login.microsoftonline.com/$($TenantID)";

		[Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]$AuthenticationContext = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext($Authority);

		$Global:AzureAuthenticationContext = $AuthenticationContext;
		$Global:AzureAuthenticationResult = $AuthenticationContext.AcquireToken($resourceAppIdURI, $ApplicationID, $Uri, "Auto");

		return $AuthenticationContext;
	}
	catch
	{
		throw $Error;
	}
}
function Get-AzureSubscription
{
	param
	(
		[switch]$AsJson
	)
	try
	{
		$ErrorActionPreference = 'Stop';
		$Error.Clear();

		$Method = 'GET';
		$apiVersion = '2015-01-01';
		$Uri = "https://management.azure.com/subscriptions?&api-version=$($apiVersion)";

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
function Select-AzureSubscription
{
	param
	(
		[object]$Subscription
	)
	try
	{
		$ErrorActionPreference = 'Stop';
		$Error.Clear();

		if ($Subscription.subscriptionId)
		{
			$Global:AzureSubscription = $Subscription;
		}
		else
		{
			throw "No subscription found";
		}
	}
	catch
	{
		throw $Error;
	}
}