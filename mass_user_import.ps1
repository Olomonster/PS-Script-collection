# Import active directory module for running AD cmdlets
Import-Module activedirectory
  
#Store the data from ADUsers.csv in the $ADUsers variable
$ADUsers = Import-Csv C:\Path\To\Data.csv -Delimiter ";"

#Loop through each row containing user details in the CSV file 
foreach ($User in $ADUsers)
{
	#Read user data from each field in each row and assign the data to a variable as below
		
	$Username = $User.Kennung
	$Password = $User.Password
	$Firstname = $User.Vorname
	$Lastname = $User.Nachname
    $email = $User.Email
    $Fullname = $User.Komplett
    $OE = $User.Organsiationseinheit
    $OU = "INSERT DISTINGUISHED NAME HERE"
    #$streetaddress = $User.streetaddress
    #$city       = $User.city
    #$zipcode    = $User.zipcode
    #$state      = $User.state
    #$country    = $User.country
    #$telephone  = $User.telephone
    #$jobtitle   = $User.jobtitle
    #$company    = $User.company
    #$department = $User.department


	#Check to see if the user already exists in AD
	if (Get-ADUser -F {SamAccountName -eq $Username})
	{
		 #If user does exist, give a warning
		 Write-Warning "A user account with username $Username already exist in Active Directory."
        # Remove-ADUser -Identity $Username -Verbose
	}
	
else
	{
		#User does not exist then proceed to create the new user account
		
        #Account will be created in the OU provided by the $OU variable read from the CSV file
		        New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@domain.com" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -DisplayName "$Lastname, $Firstname" `
            -EmailAddress $email `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -ChangePasswordAtLogon $True `
            -Name $Fullname `
            -HomeDrive "Z:" `
            -HomeDirectory "\\home\userpath" `
            -Description "$Username - $OE" `
            -Path $OU `
            -Verbose #FullDetailed
            
	}
}
