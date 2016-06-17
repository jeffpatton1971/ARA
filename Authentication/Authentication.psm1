function New-AzureContext
{
	param
	(
		[string]$TenantID,
		[string]$ApplicationID,
		[string]$CallbackUri,
		[switch]$ARM
	)

	try
	{
		$ErrorActionPreference = 'Stop';
		$Error.Clear();

		$adal = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll";
		[System.Reflection.Assembly]::LoadFrom($adal) |Out-Null;

		$Authority = "https://login.microsoftonline.com/$($TenantID)/oauth2/authorize";
		if ($ARM)
		{
			$resourceAppIdURI = "https://management.azure.com/";
		}
		else
		{
			$resourceAppIdURI = "https://management.core.windows.net/";
		}

		[System.Uri]$Uri = New-Object System.Uri($CallbackUri);
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
	try
	{
		$ErrorActionPreference = 'Stop';
		$Error.Clear();

		$Method = 'GET';
		$apiVersion = '2015-01-01';
		$Uri = "https://management.azure.com/subscriptions?&api-version=$($apiVersion)";

		Invoke-AzureRestAPI -Method $Method -apiVersion $apiVersion -AuthenticationResult $Global:AzureAuthenticationResult -Uri $Uri;
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