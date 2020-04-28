variable "name" {
  type        = string
  description = "The name of the authorization function e.g. authorize"
}

variable "jwks_uri" {
  type        = string
  description = "The URL of the JWKS endpoint (to get the public keys used to sign the JWT) https://example.auth0.com/.well-known/jwks.json"
}

variable "token_issuer" {
  type        = string
  description = "The JWT issuing authority (to check the issuer inside the token) e.g. https://example.auth0.com"
}

variable "audience" {
  type = string
  description = "The audience identifier value of the API e.g. https://api.example.com"
}