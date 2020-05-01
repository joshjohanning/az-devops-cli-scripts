###############################
# Reparent work item
###############################

# Prerequisites:
# az devops login (then paste in PAT when prompted)

# Inputs
$org="jjohanning0798"
$project="TailwindTraders"
$tag="Reparent" # only one tag is supported, would have to add another clause in the $wiql 
$newParentId="223"

az devops configure --defaults organization="https://dev.azure.com/$org" project="$project"

$wiql="select [ID], [Title] from workitems where [Tags] CONTAINS '$tag' order by [ID]"

$query=az boards query --wiql $wiql | ConvertFrom-Json

ForEach($workitem in $query) {
    $links=az boards work-item relation show --id $workitem.id | ConvertFrom-Json
    ForEach($link in $links) {
        if($link.relations.rel -eq "Parent") {
            $parentId=$link.relations.url.Split("/")[-1]
            if($parentId -ne $newParentId) {
                write-host "Unparenting" $link.id "from $parentId"
                az boards work-item relation remove --id $link.id --relation-type "parent" --target-id $parentId --yes

                write-host "Parenting" $link.id "to $newParentId"
                az boards work-item relation add --id $link.id --relation-type "parent" --target-id $newParentId
            }
            else {
                write-host "Work item" $link.id "is already parented to $parentId"
            }
        }
    }
}
