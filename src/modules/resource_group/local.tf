locals{
    resource_groups = {
        for rg in flatten([
        for rg_ in try(var.resource_groups, []): merge(
            {
                location = rg_.location
                resource_group_name = rg_.name
            }, rg_
        )]) :rg.resource_group_name => rg
    }
}