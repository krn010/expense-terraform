env          = "dev"
project_name = "expense"
kms_key_id   = "arn:aws:kms:us-east-1:058264276232:key/e83848eb-87eb-4ed9-970b-9fa81dbc7b49"

vpc = {
  main = {
    vpc_cidr = "10.10.0.0/21"
    public_subnets_cidr = ["10.10.0.0/25", "10.10.0.128/25"]
    web_subnets_cidr = ["10.10.1.0/25", "10.10.1.128/25"]
    app_subnets_cidr = ["10.10.2.0/25", "10.10.2.128/25"]
    db_subnets_cidr = ["10.10.3.0/25", "10.10.3.128/25"]
    az = ["us-east-1a", "us-east-1b"]
  }
}

rds = {
   main = {
     allocated_storage    = 10
     db_name              = "expense"
     engine               = "mysql"
     engine_version       = "5.7"
     instance_class       = "db.t3.micro"
     family               = "mysql5.7"

   }
}
