import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import * as https from 'https';

const confirmEmail = async (event: APIGatewayProxyEvent) => {
  const {
    client_id: clientId,
    user_name: userName,
    confirmation_code: confirmationCode,
    redirect_uri: redirectUri,
  } = event.queryStringParameters;

  let err = undefined;

  if (!clientId) err = 'client_id param is required';
  if (!userName) err = 'user_name param is required';
  if (!confirmationCode) err = 'confirmation_code param is required';
  if (!redirectUri) err = 'redirect_uri param is required';

  if (err !== undefined) {
    console.error(`Error: ${err}`);
    const errorResponse: APIGatewayProxyResult = {
      statusCode: 400,
      body: JSON.stringify({ error: err }),
      headers: {
        'Content-Type': 'application/json',
      },
    };
    return errorResponse;
  }

  const requestPromise = (url) => {
    return new Promise((resolve, reject) => {
      https.get(url, (res) => {
        // note: これがないと `res.on('end', ...)` イベントが発火しないので要注意
        res.on('data', () => {
          return;
        });

        res.on('error', (e) => {
          console.error(`Error: ${e.message}`);
        });
        res.on('end', () => {
          if (
            res.statusCode !== undefined &&
            res.statusCode >= 200 &&
            res.statusCode <= 299
          ) {
            resolve(res.statusCode);
          } else {
            reject(
              new Error(
                `The request has failed by status code ${res.statusCode}`
              )
            );
          }
        });
      });
    });
  };

  const authUrl = `${
    process.env.COGNITO_BASE_URL
  }/confirmUser?client_id=${clientId}&user_name=${encodeURIComponent(
    userName
  )}&confirmation_code=${confirmationCode}`;

  await requestPromise(authUrl)
    .then((httpStatusCode: number) => {
      console.log(`The request has succeed by status code ${httpStatusCode}`);
    })
    .catch((error) => console.error(error));

  const response: APIGatewayProxyResult = {
    statusCode: 302,
    headers: {
      Location: redirectUri,
      'Content-Type': 'text/plain',
    },
    body: `Redirecting to ${redirectUri}`,
  };
  return response;
};

export const main = confirmEmail;
