<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Verify Your Email</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f8fafc;
        }

        .container {
            background: white;
            border-radius: 16px;
            padding: 40px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
        }

        .logo {
            text-align: center;
            margin-bottom: 30px;
        }

        .logo h1 {
            color: #6366f1;
            font-size: 28px;
            margin: 0;
        }

        h2 {
            color: #1e293b;
            margin-bottom: 20px;
        }

        .otp-code {
            background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
            color: white;
            font-size: 32px;
            font-weight: bold;
            letter-spacing: 8px;
            text-align: center;
            padding: 20px 30px;
            border-radius: 12px;
            margin: 30px 0;
        }

        .message {
            color: #64748b;
            margin-bottom: 20px;
        }

        .warning {
            background: #fef3c7;
            border-left: 4px solid #f59e0b;
            padding: 12px 16px;
            border-radius: 0 8px 8px 0;
            color: #92400e;
            font-size: 14px;
        }

        .footer {
            text-align: center;
            color: #94a3b8;
            font-size: 12px;
            margin-top: 30px;
        }
    </style>
</head>

<body>
    <div class="container">
        <div class="logo">
            <h1>🛒 Shop</h1>
        </div>

        <h2>Welcome, {{ $name }}!</h2>

        <p class="message">
            Thank you for creating an account. Please use the verification code below to complete your registration:
        </p>

        <div class="otp-code">{{ $otp }}</div>

        <div class="warning">
            ⏱️ This code will expire in <strong>10 minutes</strong>. Please do not share this code with anyone.
        </div>

        <p class="message" style="margin-top: 20px;">
            If you didn't create an account with us, please ignore this email.
        </p>

        <div class="footer">
            <p>© {{ date('Y') }} Shop App. All rights reserved.</p>
        </div>
    </div>
</body>

</html>