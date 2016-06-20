function Invoke-AzureRestAPI
{
	param
	(
		[string]$Method,
		[string]$apiVersion,
		[Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationResult]$AuthenticationResult = $Global:AzureAuthenticationResult,
		[string]$Uri,
		[string]$Payload
	)

	try
	{
		$ErrorActionPreference = 'Stop';
		$Error.Clear();

		$AuthenticationHeader = $AuthenticationResult.CreateAuthorizationHeader();
		$Headers = @{"x-ms-version"="$apiVersion";"Authorization" = $AuthenticationHeader};

		switch ($Method)
		{
			'GET'
			{
				$Result = Invoke-RestMethod -Uri $URI -Method $Method -Headers $Headers -ContentType 'application/json';
			}
			'PUT'
			{
				$Result = Invoke-RestMethod -Uri $URI -Method $Method -Headers $Headers -ContentType 'application/json' -Body $Payload;
			}
		}
		
		if ($Result.value)
		{
			$Result |Select-Object -ExpandProperty Value;
		}
		else
		{
			$Result
		}
	}
	catch
	{
		throw $Error;
	}
}

function Template-Cmdlet
{
	param
	(
		[string]$SubscriptionId = $Global:AzureSubscription.subscriptionId,
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
		# Insert code here
		#

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