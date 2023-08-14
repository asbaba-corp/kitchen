locals{
  tables = {
    Users = {
      hash_key    = "id"
      range_key   = "created_at"
      attributes = [
        {
          name = "id"
          type = "S"
        },
        {
          name = "email"
          type = "S"
        },
        {
          name = "password"
          type = "S"
        },
        {
          name = "created_at"
          type = "S"
        }
      ]
    },
    Recipes = {
      hash_key    = "id"
      range_key   = "created_at"
      attributes = [
        {
          name = "id"
          type = "S"
        },
        {
          name = "creator_id"
          type = "S"
        },
        {
          name = "ingredients"
          type = "SS"
        },
        {
          name = "name"
          type = "S"
        },
         {
          name = "created_at"
          type = "S"
        }
      ]
    },
    Ingredients = {
      hash_key    = "id"
      range_key   = "created_at"
      attributes = [
        {
          name = "id"
          type = "S"
        },
        {
          name = "name"
          type = "S"
        } 
      ]
    }
  }  
}


module "dynamodb_table" {
   for_each = local.tables

  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "3.3.0"

  name                        = each.key
  hash_key                    = each.value.hash_key
  range_key                   = each.value.range_key
  table_class                 = "STANDARD"
  deletion_protection_enabled = false

  attributes = each.value.attributes

  tags = {
    Deployment = "terraform"
  }
}


