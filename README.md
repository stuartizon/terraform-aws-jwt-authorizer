# Terraform AWS JWT Authorizer
Terraform module which creates a custom lambda authorizer to secure APIs registered with API gateway.

The authorizer checks:
- an access token has been passed via the authorization header of the request
- the RS256 signature of the access token is valid using a public key obtained from a JWKS endpoint
- the access token has the required issuer and audience claims

The approach here is based on https://auth0.com/docs/integrations/aws-api-gateway-custom-authorizers

## Usage
```hcl
module "authorizer" {
  source = "stuartizon/jwt-authorizer/aws"
  version = "~> 1.0.0"
  name = "authorizer_staging"
  audience = "api.example.com"
  jwks_uri = "example.auth_domain.com/.well-known/jwks.json"
  token_issuer = "example.auth_domain.com/"
}
```

## Variables
| Name | Type | Description | Default |
|------|------|-------------|---------|
| name | `string` | The name of the authorization lambda function to create | |
| jwks_uri | `string` | The URL of the JWKS endpoint (to get the public keys used to sign the JWT) | |
| token_issuer | `string` | The JWT issuing authority (to check the issuer inside the token) | |
| audience | `string` | The audience identifier value of the API | |

## Outputs
| Name | Description |
|------|-------------|
| invoke_arn | The ARN to be used for invoking the lambda function from API Gateway |

# Development
Since the way that Terraform modules are published to the Terraform Registry works using git and release tags, the compiled javascript file is checked into the repository. There is a precommit hook to automatically trigger javascript compilation. 

The version number is also present, naturally, in the package.json. Using `release-it` as part of the CI, this version is incremented and a new tag created on every git push.