# Let's Encrypt add-on using TLS-ALPN-01 challenge

This is a Home Assistant add-on for getting Let's Encrypt certificate with [uacme](https://github.com/ndilieto/uacme) using [TLS-ALPN-01](https://letsencrypt.org/docs/challenge-types/#tls-alpn-01) challenge.

Suppose your DNS provider does not support Let's Encrypt DNS challenge, and you don't want to open port 80 for HTTP challenge either. If your reverse proxy supports TLS/SSL probing, this addon is for you.

I guess not many people have this setup for their home network, that's why I haven't found an existing add-on, so I created this one. It has the bare minimum functionality, but works.

## Usage

1. In Home Assistant, go to **Settings → Add-ons → Add-on Store**, click the three dots (⋮) in the top right, and select **Repositories**. Add `https://github.com/newash/home-assistant-addons`.
1. Install the add-on from the store.
1. Configure the add-on setting these options:
   - **domain**: Your domain name to obtain a certificate for.
   - **certfile**: Name of the file where the issued certificate will be saved (inside `/ssl/` where it's normally expected to be). You can keep the default `fullchain.pem` value.
   - **keyfile**: Name of the file where the private key will be saved. You can keep the default `privkey.pem` value.
   - **network port**: The port of the Home Assistant server the TLS-ALPN-01 challenge responses should be received on. This is the port that has to be set on the reverse proxy separately. It's not your regular HTTPS port.
1. Since the add-on does not run in the background but shuts down after each certificate refresh, an automation has to be set with **Settings → Automations & scenes → Create automation**. After setting the trigger condition (e.g. once a week) choose the _"Home Assistant Supervisor: Restart add-on"_ action, select the _"uacme TLS-ALPN-01"_ from the dropdown and **Save**.
1. To enable HTTPS for Home Assitant, the following lines have to be added to the main configuration file `configuration.yaml`, using the values from **certfile** and **keyfile** above:
   ```yaml
   http:
     ssl_certificate: /ssl/fullchain.pem
     ssl_key: /ssl/privkey.pem
   ```
1. Set your reverse proxy to forward the reqests with _"acme-tls/1"_ ALPN protocol to the local IP and the port (set above) of the Home Assistant server.\
I'm using [sslh](https://github.com/yrutschle/sslh) proxy and this is how its `/etc/sslh.conf` config looks like:
   ```js
   protocols:
   (
       ...
       { name: "tls";
         host: "<Home Assistant server local IP>";
         port: "<the network port from the config above>";
         alpn_protocols: [ "acme-tls/1" ];
         sni_hostnames: [ "your.domain.name" ];
       },
       ...
   );
   ```
1. Now you have everything set up for the certificate renewal, but you still don't have the certificate because the add-on hasn't been run yet. Go to the add-on page and press **Start**. You can check if everything went fine on the **Log** tab.
1. Finally, if you also have the Home Assistant web port (default 8123) proxied or forwarded on your router, you can access it with HTTPS.