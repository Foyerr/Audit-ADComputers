function Update-ADObjectHelper {
param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
	    [string]$Identity,

	    [ValidatePattern("^\S(.*\S)?$")]
        [Parameter(Mandatory=$false)]
        [string]$NewName="",

        [Parameter(Mandatory=$false)]
        [string]$AdMessage,

        [Parameter(Mandatory=$false)]
	    [ValidatePattern("^(OU\=.*,\DC\=.*)$")]
        [string]$TargetPath,

        [Parameter(Mandatory=$false)]
        [switch]$remove,

        [Parameter(Mandatory=$false)]
        [switch]$disable,

        [Parameter(Mandatory=$false)]
	    [ValidateScript({
            $parent = Split-Path -Path $_
            return (Test-Path -Path $parent -PathType Container)
        })]
        [string]$errorLogPath=""
    )


    if(!(Test-Path -path $errorLogPath)){
        Out-File $errorLogPath
    }

    $removedCounter=0
    $disabledCounter=0
    $adMessageCounter=0
    $renameCounter=0
    $movedCounter=0


    if($remove){
        try{
            Remove-ADObject -Identity $Identity -Recursive -Confirm:$false
            $removedCounter++ 
        }catch{
            $errorMessage = "Unable to remove: $Identity"
            Add-Content -Path $errorLogPath -Value "$($errorMessage)"

        }
    }

    #disable computer account
    if($disable){
        try{
            Set-ADComputer -Identity $Identity -Enabled $false
            $disabledCounter++
        }catch{
            $errorMessage = "Unable to Disable: $Identity"
            Add-Content -Path $errorLogPath -Value "$($errorMessage)"
        }
    }

    # Append administrative message to the 'info' attribute of the AD object if provided
    if ($AdMessage) {
        try {
            $existingInfo = (Get-ADObject -Identity $Identity -Properties info).info
            $newInfo = "$AdMessage`r`n$existingInfo"
            Set-ADObject -Identity $Identity -Replace @{info=$newInfo}
            $adMessageCounter++
        } catch {
            $errorMessage =  "Could not append message to AD object ($Identity): $_"
            Add-Content -Path $errorLogPath -Value "$($errorMessage)"
        }
    }

     # Rename the AD object if a new name is provided
    if ($NewName) {
        try {
            Rename-ADObject -Identity $Identity -NewName $NewName
            $renameCounter++
        } catch {
            $errorMessage = "Could not rename AD object ($Identity) to new name ($NewName): $_"
            Add-Content -Path $errorLogPath -Value "$($errorMessage)"
        }
    }

    # Move the AD object to a new OU if a target path is provided
    if ($TargetPath) {
        try {
            $pattern = '^(.*?\=).*?(\,.*)$'
            $result = $Identity -replace $pattern, "`$1$NewName`$2"
            Move-ADObject -Identity "$result" -TargetPath $TargetPath
            $movedCounter++
        } catch {
            $errorMessage =  "Could not move AD object ($Identity) to OU ($TargetPath): $_"
            Add-Content -Path $errorLogPath -Value "$($errorMessage)"
        }
    }
    #I could simplify this to a byte 00000000 and flip each bit to represent each true result
    $results = [PSCustomObject]@{
            Removed    = $removedCounter
            Disabled   = $disabledCounter
            adMessage  = $adMessageCounter
            Renamed    = $renameCounter
            Moved      = $movedCounter
        }

    return $results
}
