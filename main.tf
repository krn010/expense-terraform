#module "vpc" {
  #source               = "./modules/vpc"

  #for_each             = var.vpc
  #vpc_cidr             = lookup(each.value, "vpc_cidr", null)
  #public_subnets_cidr  = lookup(each.value, "public_subnets_cidr", null)
  #az                   = lookup(each.value, "az", null)
  #web_subnets_cidr     = lookup(each.value, "web_subnets_cidr", null)
  #app_subnets_cidr     = lookup(each.value, "app_subnets_cidr", null)
  #db_subnets_cidr      = lookup(each.value, "db_subnets_cidr", null)

  #env                  = var.env
  #project_name         = var.project_name
#}

#module "rds" {
  #source               = "./modules/rds"

  #for_each             = var.rds
  #allocated_storage    = lookup(each.value, "allocated_storage", null )
  #db_name              = lookup(each.value, "db_name", null )
  #engine               = lookup(each.value, "engine", null )
  #engine_version       = lookup(each.value, "engine_version", null )
  #instance_class       = lookup(each.value, "instance_class", null )
  #family               = lookup(each.value, "family", null )

  #env                  = var.env
  #project_name         = var.project_name
  #kms_key_id           = var.kms_key_id

  #subnet_ids           = lookup(lookup(module.vpc,"main", null),"db_subnets_ids", null)
  #vpc_id               = lookup(lookup(module.vpc,"main", null),"vpc_id", null)
  #sg_cidr_blocks       = lookup(lookup(var.vpc,"main", null),"app_subnets_cidr", null)


#}

module "vpc" {
  source = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  az                   = var.az
  web_subnets_cidr     = var.web_subnets_cidr
  app_subnets_cidr     = var.app_subnets_cidr
  db_subnets_cidr      = var.db_subnets_cidr

  env                  = var.env
  project_name         = var.project_name



}

module "rds" {
  source = "./modules/rds"
  allocated_storage    = var.rds_allocated_storage
  db_name              = var.rds_db_name
  engine               = var.rds_engine
  engine_version       = var.rds_engine_version
  instance_class       = var.rds_instance_class
  family               = var.rds_family

  env                  = var.env
  project_name         = var.project_name
  kms_key_id           = var.kms_key_id

  subnet_ids           = module.vpc.app_subnets_ids
  vpc_id               = module.vpc.vpc_id
  sg_cidr_blocks       = var.app_subnets_cidr
}

module "backend" {
  source = "./modules/app"

  app_port            = var.backend_app_port
  bastion_cidrs       = var.bastion_cidrs
  component           = "backend"
  env                 = var.env
  instance_capactiy   = var.backend_instance_capactiy
  instance_type       = var.backend_instance_type
  project_name        = var.project_name
  sg_cidr_blocks      = var.web_subnets_cidr
  vpc_id              = module.vpc.vpc_id
  vpc_zone_identifier = module.vpc.app_subnets_ids
}

module "frontend" {
  source = "./modules/app"

  app_port            = var.frontend_app_port
  bastion_cidrs       = var.bastion_cidrs
  component           = "frontend"
  env                 = var.env
  instance_capactiy   = var.frontend_instance_capactiy
  instance_type       = var.frontend_instance_type
  project_name        = var.project_name
  sg_cidr_blocks      = var.web_subnets_cidr  # This needs to be checked
  vpc_id              = module.vpc.vpc_id
  vpc_zone_identifier = module.vpc.app_subnets_ids
}

module "public-alb" {
  source = "./modules/alb"

  alb_name       = "public"
  env            = var.env
  internal       = false
  project_name   = var.project_name
  sg_cidr_blocks = ["0.0.0.0/0"]
  subnets        = module.vpc.public_subnets_ids
  vpc_id         = module.vpc.vpc_id
  acm_arn        = var.acm_arn
  target_group_arn = module.frontend.target_group_arn
}

module "private-alb" {
  source = "./modules/alb"

  alb_name       = "private"
  env            = var.env
  internal       = true
  project_name   = var.project_name
  sg_cidr_blocks = var.web_subnets_cidr
  subnets        = module.vpc.app_subnets_ids
  vpc_id         = module.vpc.vpc_id
  acm_arn        = var.acm_arn
  target_group_arn = module.backend.target_group_arn
}


