const redirectUri = `${process.env.QOCOLOR_BASE_URL}/signin?redirect_path=/questionnaire`;

const getSubject = (locale = 'en') => {
  switch (locale) {
    case 'ja':
      return 'Qocolor へのご登録ありがとうございます';
    default:
      return 'Welcome to Qocolor! Please verify your Email Adress.';
  }
};

// note:
// user_name は encodeURIComponent かけないと + が空白に置換されてしまうので注意
const getEmailMessage = (
  locale = 'en',
  userName,
  confirmationCode,
  redirectUri
) => {
  switch (locale) {
    case 'ja':
      return `メールアドレスの確認を行うため、以下のリンクをクリックしてください。<br>
  <a href="${process.env.CONFIRM_EMAIL_URL}?client_id=${
        process.env.COGNITO_CLIENT_ID
      }&user_name=${encodeURIComponent(
        userName
      )}&confirmation_code=${confirmationCode}&redirect_uri=${redirectUri}">メールアドレスを確認</a>
`;
    default:
      return `Please click the below link to verify your email address.<br>
  <a href="${process.env.CONFIRM_EMAIL_URL}?client_id=${
        process.env.COGNITO_CLIENT_ID
      }&user_name=${encodeURIComponent(
        userName
      )}&confirmation_code=${confirmationCode}&redirect_uri=${redirectUri}">Verify Email</a>
`;
  }
};

const customMessage = async (event, _, callback) => {
  if (event.triggerSource === 'CustomMessage_SignUp') {
    event.response.emailSubject = getSubject(
      event.request.userAttributes.locale
    );
    event.response.emailMessage = getEmailMessage(
      event.request.userAttributes.locale,
      event.request.userAttributes.email,
      event.request.codeParameter,
      redirectUri
    );
  }

  callback(null, event);
};

export const main = customMessage;
