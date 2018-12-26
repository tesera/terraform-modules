<h1>IAM User Details</h1>
<p>
    Your IAM account for AWS access has been created. Following are the
    account details. The included password is temporary and you will need
    to change the password on your first login. You should try signing into
    AWS console and change the password immediately and add a MFA device to
    your account.
</p>
<p>
    <b>Login URL:</b>
    <a href="https://__ALIAS__.signin.aws.amazon.com/console">
        https://__ALIAS__.signin.aws.amazon.com/console
    </a>
</p>
<p><b>Account ID or alias:</b> <code>__ALIAS__</code></p>
<p><b>IAM user name:</b> <code>__USERNAME__</code></p>
<p><b>Password:</b> <code>__PASSWORD__</code></p>

<h2>Setup MFA</h2>
<ol>
    <li>Go to <a href="https://console.aws.amazon.com/iam/home?region=us-east-1#/users/__USERNAME__?section=security_credentials">
            https://console.aws.amazon.com/iam/home?region=us-east-1#/users/__USERNAME__?section=security_credentials
        </a></li>
    <li>Press <b>Manage</b> under <i>Assigned MFA device</i>.</li>
    <li>Choose <i>Virtual device</i> and press <b>Continue</b>.</li>
    <li>Scan QRCode into MFA device, enter two MFA codes and press <b>Assign MFA</b>.</li>
    <li>Press <b>Close</b>.</li>
</ol>
<p>
    Thanks,<br/>
    The Wizard of Oz
</p>
