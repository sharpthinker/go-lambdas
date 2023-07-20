resource "aws_route53_record" "jb_wh1sk_one-default" {
    name                             = "api.jb.wh1sk.one"
    set_identifier                   = "us-east-1-apiGW"
    type                             = "A"
    zone_id                          = "Z05237732RIEI9IYTMZZ6"

    alias {
        evaluate_target_health = true
        name                   = "d-eqx16c3u4j.execute-api.us-east-1.amazonaws.com"
        zone_id                = "Z1UJRXOUMOOFQ8"
    }

    geolocation_routing_policy {
        country = "*"
    }
}