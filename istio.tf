
// this will install the base componets of istio ex:- gateway,virtualservice,destinationrule,serviceentry
resource "helm_release" "istio_base" {

  name = "istio-base"

  repository = "https://istio-release.storage.googleapis.com/charts"

  chart = "base"

  namespace = "istio-system"

  create_namespace = true
  wait = true
  reset_values = true

  version = "1.21.2"
}
// creates pods
resource "helm_release" "istiod" {

  depends_on = [
    helm_release.istio_base
  ]

  name = "istiod"

  repository = "https://istio-release.storage.googleapis.com/charts"

  chart = "istiod"

  namespace = "istio-system"

  version = "1.21.2"
  reset_values = true

  set {
        name = "meshConfig.accessLogFile"
        value = "/dev/stdout"
    }
}

// installing istio gateway
resource "helm_release" "istio_gateway" {

  depends_on = [
    helm_release.istiod
  ]

  name = "istio-ingressgateway"

  repository = "https://istio-release.storage.googleapis.com/charts"

  chart = "gateway"

  namespace = "istio-system"

  version = "1.24.0"

  values = [file("istio_gateway_values.yaml")]
}
