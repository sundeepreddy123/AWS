
// this will install the base componets of istio ex:- gateway,virtualservice,destinationrule,serviceentry
resource "helm_release" "istio_base" {

  name = "istio-base"

  repository = "https://istio-release.storage.googleapis.com/charts"

  chart = "base"

  namespace = "istio-system"

  create_namespace = true
  wait = true
  reset_values = true

  version = "1.30.2"

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

  version = "1.30.2"
  reset_values = true

#   values = [file("istiod-values.yaml")]

}

// installing istio gateway
resource "helm_release" "istio_ingress" {

  depends_on = [
    helm_release.istiod
  ]

  name = "istio-ingressgateway"

  repository = "https://istio-release.storage.googleapis.com/charts"

  chart = "gateway"

  namespace = "istio-system"
  create_namespace = true
  timeout = 1200

  version = "1.30.2"
  wait = true
  reset_values = true

  values = [file("istio/values-istio.yaml")]
}

# resource "helm_release" "istio_ingress-internal" {

#   depends_on = [
#     helm_release.istiod
#   ]

#   name = "istio-ingress-internal"

#   repository = "https://istio-release.storage.googleapis.com/charts"

#   chart = "gateway"

#   namespace = "istio-ingress-internal"
#   create_namespace = true
#   timeout = 1200

#   version = "1.28.10"
#   wait = true
#   reset_values = true

#   values = [file("istio/values-${var.env}-int.yaml")]
# }
