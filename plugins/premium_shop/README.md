# Premium Shop

1. Create an Restricted API key in [the Stripe Dashboard](https://dashboard.stripe.com/test/apikeys/create):

    * Checkout Sessions: `Write`

2. Create a copy of the `.env.example` file and rename it to `.env` in the root of your plugin directory.

3. Ensure the game server has access to the environment file (e.g: `sudo chown www-data:www-data .env`)
