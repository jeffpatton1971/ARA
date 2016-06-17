function Invoke-AzureRestAPI
{
	param
	(
		[string]$Method,
		[string]$apiVersion,
		[Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationResult]$AuthenticationResult = $Global:AzureAuthenticationResult,
		[string]$Uri
	)

	try
	{
		$ErrorActionPreference = 'Stop';
		$Error.Clear();

		$AuthenticationHeader = $AuthenticationResult.CreateAuthorizationHeader();
		$Headers = @{"x-ms-version"="$apiVersion";"Authorization" = $AuthenticationHeader};

		$Result = Invoke-RestMethod -Uri $URI -Method $Method -Headers $Headers -ContentType 'application/json';
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