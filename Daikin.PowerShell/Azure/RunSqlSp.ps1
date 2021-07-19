Param
(
[Parameter (Mandatory= $true)]
[String] $CredentialName,
[Parameter (Mandatory= $true)]
[String] $SqlServer,
[Parameter (Mandatory= $true)]
[String] $Database = "iep-prod",
[Parameter (Mandatory= $true)]
[String] $StoredProc,
[Parameter (Mandatory= $true)]
[int] $DaysToSave = 1
)
   $Credentials = Get-AutomationPSCredential  -Name $CredentialName
    # Get the username and password from the SQL Credential
    $SqlUsername = $Credentials.UserName 
    $SqlPass = $Credentials.GetNetworkCredential().Password
    
        # Define the connection to the SQL Database
        $Conn = New-Object System.Data.SqlClient.SqlConnection("Server=tcp:$SqlServer,1433;Database=$Database;User ID=$SqlUsername;Password=$SqlPass;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;")
        
        # Open the SQL connection
        $Conn.Open()
        # Define the SQL command to run. In this case we are getting the number of rows in the table
        $Cmd=new-object system.Data.SqlClient.SqlCommand($StoredProc, $Conn)
        $Cmd.CommandTimeout=120
        # Execute the SQL command
        $Ds=New-Object system.Data.DataSet
        $Da=New-Object system.Data.SqlClient.SqlDataAdapter($Cmd)
        [void]$Da.fill($Ds)
        # Output the count
        $Ds.Tables.Column1
        # Close the SQL connection
        $Conn.Close()
    


