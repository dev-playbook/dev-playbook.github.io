---
layout: page
---
# Create custom Windows image using Powershell

Connect-AzAccount -Subscription 'Personal'

Get-AzPublicIpAddress -ResourceGroupName 'psdemo-rg' -Name psdemo-win-1-pip-1

    #open rdp and run this
    %WINDIR%\system32\sysprep\sysprep.exe /generalize /shutdown /oobe

Get-AzVm -ResourceGroupName 'psdemo-rg' -Name psdemo-win-1 -Status

$rg = Get-AzResourceGroup -Name psdemo-rg -Location 'Central US'

$vm = Get-AzVm -ResourceGroupName psdemo-rg -Name psdemo-win-1

# deallocate
Stop-AzVM -ResourceGroupName $rg.ResourceGroupName -Name $vm.Name -Force

Get-AzVM -ResourceGroupName $rg.ResourceGroupName -Name $vm.Name -Status

#mark vm as generalized
Set-AzVM -ResourceGroupName $rg.ResourceGroupName -Name $vm.Name -Generalized

# start image config
$image = New-AzImageConfig -Location $rg.Location -SourceVirtualMachineId $vm.ID

# create custom image
New-AzImage -ResourceGroupName $rg.ResourceGroupName -Image $image -ImageName psdemo-win-ci-1

Get-AzImage -ResourceGroupName $rg.ResourceGroupName



# create windows vm from custom vm 

$password = ConvertTo-SecureString 'Rwwgecat123456789' -AsPlainText -Force
$WindowsCred = New-Object System.Management.Automation.PSCredential ('demoadmin', $password)

$vmParams = @{
    ResourceGroupName = $rg.ResourceGroupName
    Name = 'psdemo-win-1c'
    Image = 'psdemo-win-ci-1'
    Location = 'centralus'
    Credential = $WindowsCred
    VirtualNetworkName = 'psdemo-vnet-2'
    SubnetName = 'psdemo-subnet-2'
    SecurityGroupName = 'psdemo-win-nsg-2'
    OpenPorts = 3389
}
New-AzVM @vmParams

Get-AzVm -ResourceGroupName $rg.ResourceGroupName -Name psdemo-win-1c -Status

Remove-AzVm -ResourceGroupName $rg.ResourceGroupName -Name psdemo-win-1