import os
import urllib.request
import json

SLACK_WEBHOOK_URL = os.environ['SLACK_WEBHOOK_URL']

def handler(event, context):
    print(event)

    subject = event['Records'][0]['Sns']['Subject']
    message = event['Records'][0]['Sns']['Message']
    critical = False # Tips: 必要に応じて関数や題名等で切り替え

    # JSON整形
    try:
        message = json.dumps(json.loads(message), indent = '\t')
    except:
        pass

    # Slack通知
    data = {
        'text': (':red_circle:' if critical else ':warning:') + ' AWS Notifications',
        'attachments':  [{
            'pretext': ('<!channel>' if critical else '<!here>'),
            'color': ('danger' if critical else 'warning'),
            'fields': [{
                'title': subject,
                'value': message
            }]
        }]
    }
    request = urllib.request.Request(
        url = SLACK_WEBHOOK_URL,
        data = json.dumps(data).encode('utf-8'),
        method = 'POST',
        headers = { 'Content-Type': 'application/json; charset=utf-8' }
    )
    with urllib.request.urlopen(request) as response:
        print(response.read().decode('utf-8'))
