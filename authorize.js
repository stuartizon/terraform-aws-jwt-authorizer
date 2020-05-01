import { promisify } from "util";
import { decode, verify } from "jsonwebtoken";
import jwksRsa from "jwks-rsa";

const client = jwksRsa({
  cache: true,
  rateLimit: true,
  jwksUri: process.env.JWKS_URI,
});

const getSigningKey = promisify(client.getSigningKey);

const verifyToken = promisify(verify);

function getToken(event) {
  return event.authorizationToken.replace("Bearer ", "");
}

export function decodeToken(token) {
  const decoded = decode(token, { complete: true });
  if (!decoded || !decoded.header || !decoded.header.kid) {
    throw new Error("Invalid token");
  }
  return decoded;
}

function generatePolicy(methodArn) {
  return {
    Version: "2012-10-17",
    Statement: [
      {
        Action: "execute-api:Invoke",
        Effect: "Allow",
        Resource: methodArn,
      },
    ],
  };
}

export async function handler(event) {
  console.log(event);

  try {
    const token = getToken(event);
    const decodedToken = decodeToken(token);
    const signingKey = await getSigningKey(decodedToken.header.kid);
    const publicKey = signingKey.getPublicKey();
    const { sub, scope } = await verifyToken(token, publicKey, {
      audience: process.env.AUDIENCE,
      issuer: process.env.TOKEN_ISSUER,
    });

    return {
      principalId: sub,
      policyDocument: generatePolicy(event.methodArn),
      context: { scope },
    };
  } catch (e) {
    console.log(e);
    return `Unauthorized ${e}`;
  }
}
