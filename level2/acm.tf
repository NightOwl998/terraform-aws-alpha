data "aws_route53_zone" "main" {
  name = "fadiatestdevops.click"

}
#  module "zones" {

#    source  = "terraform-aws-modules/route53/aws//modules/zones"
#   version = "~> 2.0"
#   create=false
#   zones = "fadiatestdevops.click" 
# }

module "dns" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_id = data.aws_route53_zone.main.zone_id


  records = [
    {
      name    = "www"
      type    = "CNAME"
      records = [module.lb.lb_dns_name]
      ttl     = 3600
    }

  ]


}
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "www.${data.aws_route53_zone.main.name}"
  zone_id     = data.aws_route53_zone.main.zone_id



  wait_for_validation = true

  tags = {
    Name = "my-domain.com"
  }
}
