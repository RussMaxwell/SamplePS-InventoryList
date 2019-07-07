function setupList ($tempCT)
{
    try {

        if(!(Get-PnPList -Identity 'ContosoUsedCars'))
        {
            $list = New-PnPList -Title 'ContosoUsedCars' -Template 'GenericList' -EnableContentTypes
            Write-Host 'List Created' -ForegroundColor Green
        }

        else 
        {
            $list = Get-PnPList -Identity 'ContosoUsedCars'
            Write-Host 'List Found!' -ForegroundColor Cyan
        }
        

        if(!(Get-PnPContentType -List 'ContosoUsedCars' | ?{$_.Name -eq 'TestCT'}))
        {
            Add-PnPContentTypeToList -ContentType $tempCT -List $list -DefaultContentType
            Write-Host 'ContentType added to list' -ForegroundColor Green
        }
       
        else 
        {Write-Host "ContentType already added to list" -ForegroundColor Cyan}

        if(!(Get-PnPView -List 'ContosoUsedCars' | ?{$_.Title -eq 'MyNewView'}))
        {
            Add-PnPView -Title 'MyNewView' -List $list -Fields 'Make','Model','Miles','Sold'
            Write-Host 'Custom view created' -ForegroundColor Green
        }
        else 
        {Write-Host "Custom View Found!" -ForegroundColor Cyan}
    }
    catch [Exception]
    {Write-Host "Exception caught attempting to setup list" $_.Exception -ForegroundColor Red}
}


function addColumnstoContentType ($tempCT,$myCols)
{
    $cols = $myCols
    try {
    foreach($col in $cols)
    {Add-PnPFieldToContentType -Field $col -ContentType $tempCT}

    #Go Setup List
    setupList $tempCT
    }
    catch  [Exception]  
    {Write-Host “Exception caught attempting to add site columns to content type” $_.Exception -ForegroundColor Red}   
}

function createContentType ($siteCols)
{
     try {
        if(!(get-pnpcontenttype -identity "TestCT"))
        {
            $newCT = add-pnpcontenttype -Name "TestCT" -Description "Contoso Test CT" -Group "Custom" -ParentContentType $itemCT
            Write-Host 'Created custom content type' -ForegroundColor Green
            addColumnstoContentType $newCT $siteCols
        }
    
        else
        {
            Write-Host "Content Type Found!" -ForegroundColor Cyan
            $newCT = get-pnpcontenttype -identity "TestCT"
            addColumnstoContentType $newCT $siteCols
        }
    }
    catch  [Exception] 
    {Write-Host “Exception caught attempting to create content type” $_.Exception -ForegroundColor Red}   
}


function createSiteColumns()
{
    try {
        $mySiteColumns = @()
        
        if(!(get-pnpfield | ?{$_.Title -eq 'Make'}))
        {$mySiteColumns += add-pnpfield -Type 'text' -DisplayName 'Make' -InternalName 'Make' -Group 'custom'}
        else 
        {$mySiteColumns += get-pnpfield -identity 'Make'}
            
        if(!(get-pnpfield | ?{$_.Title -eq 'Model'}))
        {$mySiteColumns += add-pnpfield -Type 'text' -DisplayName 'Model' -InternalName 'Model' -Group 'custom'}
        else 
        {$mySiteColumns += get-pnpfield -Identity 'Model'}

        if(!(get-pnpfield | ?{$_.Title -eq 'Miles'}))
        {$mySiteColumns += add-pnpfield -Type 'number' -DisplayName 'Miles' -InternalName 'Miles' -Group 'custom'}
        else
        {$mySiteColumns += get-pnpfield -Identity 'Miles'}
        
        if(!(get-pnpfield | ?{$_.Title -eq 'Sold'}))
        {$mySiteColumns += add-pnpfield -Type 'choice' -DisplayName 'Sold' -InternalName 'Sold' -Group 'custom' -choices 'Decision Pending','Yes','No'}
        else
        {$mySiteColumns += get-pnpfield -Identity 'Sold'}

        ###Go Create ContentType
        createContentType $mySiteColumns
    }
 
    catch [Exception] 
    {Write-Host “Exception caught attempting to create site columns” $_.Exception -ForegroundColor Red}
  
}


try {
##Module is loaded up so connect to tenant##
Write-Host "Connecting to your tenant"
Write-Host
Connect-PnPOnline -Url 'https://m365x475871.sharepoint.com/sites/test25' -UseWebLogin
createSiteColumns
}

catch [Exception]
{Write-Host "Module is not loaded or you hit an exception: " $_.Exception -ForegroundColor Red  }