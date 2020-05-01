$org="https://dev.azure.com/jjohanning0798"
$project="TailwindTraders"
$tag="Reparent"

az devops configure --defaults organization=$org project=$project

$wiql="select [ID], [Title] from workitems where [Tags] CONTAINS '$tag' order by [ID]"

$query=az boards query --wiql $wiql | ConvertFrom-Json

ForEach($workitem in $query) {
    #Write-Host $workitem.id
    $links=az boards work-item relation show --id $workitem.id | ConvertFrom-Json
    # $links | format-list
    ForEach($link in $links.relations.rel) {
        if($link -eq "Parent") {
            write-host "yep it's a parent"
        }
    }
    # boards work-item relation remove --id $workitem.id --relation-type "parent" --target-id
}
