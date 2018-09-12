#################################################################################################################################
# This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment. #
# THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,  #
# INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. We grant You  #
# a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of  #
# the Sample Code, provided that. You agree: (i) to not use Our name, logo, or trademarks to market Your software product in    #
# which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the Sample Code #
# is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits,  #
# including attorneys’ fees, that arise or result from the use or distribution of the Sample Code                               #
#################################################################################################################################

Param(
    $GroupName
)

$global:AddedMembers = @{}
$UnknownGroup = @{}

Function DisplayMembers($group,$AddedMembers)
{
$SubGroup = @{}
$AllMembers = @()

foreach ($member in (Get-DistributionGroupMember $group -ResultSize Unlimited)){
        $membertype = $member.RecipientTypeDetails
        if($membertype -eq "MailUniversalDistributionGroup" -or $membertype -eq "MailUniversalSecurityGroup"){
            $name = $member.Name.ToString()
            if($SubGroup.ContainsKey($name) -eq $true){
                #^ already seen group member (stopping to avoid loop)
            }
            else
            {
                $SubGroup.Add($name,$member.DisplayName.ToString())
            }
            if($global:AddedMembers.Count -eq 0){
                    $obj = new-object psObject
                    $obj | Add-Member -MemberType noteproperty -Name GroupName -Value $group
                    $obj | Add-Member -membertype noteproperty -name GroupMember -Value $member
                    $AllMembers += $obj
                    $global:AddedMembers.Add($member.Name.ToString(),$member.DisplayName.ToString())
                }
                else
                {
                    if($global:AddedMembers.ContainsKey($member.Name.ToString())){
                        #Write-Host "Membro já listado"
                    }
                    else
                    {
                        $obj = new-object psObject
                        $obj | Add-Member -MemberType noteproperty -Name GroupName -Value $group
                        $obj | Add-Member -membertype noteproperty -name GroupMember -Value $member
                        $AllMembers += $obj
                        $global:AddedMembers.Add($member.Name.ToString(),$member.DisplayName.ToString())
                    }
                }
        }
        else
        {
            if($member.RecipientTypeDetails -notmatch "group"){
                if($global:AddedMembers.Count -eq 0){
                    $obj = new-object psObject
                    $obj | Add-Member -MemberType noteproperty -Name GroupName -Value $group
                    $obj | Add-Member -membertype noteproperty -name GroupMember -Value $member
                    $AllMembers += $obj
                    $global:AddedMembers.Add($member.Name.ToString(),$member.DisplayName.ToString())
                }
                else
                {
                    if($global:AddedMembers.ContainsKey($member.Name.ToString())){
                        #Write-Host "Membro já listado"
                    }
                    else
                    {
                        $obj = new-object psObject
                        $obj | Add-Member -MemberType noteproperty -Name GroupName -Value $group
                        $obj | Add-Member -membertype noteproperty -name GroupMember -Value $member
                        $AllMembers += $obj
                        $global:AddedMembers.Add($member.Name.ToString(),$member.DisplayName.ToString())
                    }
                }
            }
        }
    }

if($SubGroup.Values.Count -gt 0){
    foreach ($subGroup in $SubGroup.values){
        DisplayMembers $subGroup -AddedMembers $global:AddedMembers
    }
}

if ($UnknownGroup.Keys.Count -gt 0){
    foreach ($LostGroup in $UnknownGroup.keys){
        $obj = new-object psObject
        $obj | Add-Member -membertype noteproperty -name GroupMember -Value "Cannot enumerate group"
        $obj | Add-Member -MemberType noteproperty -Name GroupName -Value $LostGroup
        $AllMembers += $obj
        }
        $UnknownGroup.Clear()
    } 

Write-Output $AllMembers

}
$objOut = @()

$obj = New-Object psobject -Property @{
    GroupName = $GroupName
    MemberCount = (DisplayMembers $GroupName | Measure-Object).Count
}
$objOut += $obj
$objOut