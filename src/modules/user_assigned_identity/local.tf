locals {
    user_assigned_identities = {
        for uai in flatten([
        for uai_ in try(var.user_assigned_identities, []): merge(
            {
                name = uai_.name
                location = uai_.location
                resource_group = uai_.resource_group
            }, uai_
        )]) :uai.name => uai
    }
}