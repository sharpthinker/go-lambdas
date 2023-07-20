resource "aws_route53_record" "jb_wh1sk_one-europe" {
    name                             = "api.jb.wh1sk.one"
    set_identifier                   = "eu-central-1-apiGW"
    type                             = "A"
    zone_id                          = "Z05237732RIEI9IYTMZZ6"

    alias {
        evaluate_target_health = true
        name                   = "d-uxx69r3sol.execute-api.eu-central-1.amazonaws.com"
        zone_id                = "Z1U9ULNL0V5AJ3"
    }

    geolocation_routing_policy {
        continent = "EU"
    }
}