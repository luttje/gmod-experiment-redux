# Premium Shop

1. Install [the PayNow.gg addon](https://github.com/paynow-gg/gmod-addon/tree/master) to link the game server to your account.

    This allows PayNow to send commands to your game server.

2. Create your game server [in the PayNow.gg Game Servers section](https://dashboard.paynow.gg/gameservers) and run the provided command in the server.

3. Create a copy of the `.env.example` file and rename it to `.env` in the root of your plugin directory.

4. Ensure the game server has access to the environment file (e.g: `sudo chown www-data:www-data .env`)

5. Setup the following commands in [the PayNow.gg Global Commands section](https://dashboard.paynow.gg/global-commands):
    - On Purchased: `exp_premium_order purchased {product.slug} {order.id} {order.customer.steam.id}`
    - On Expire: `exp_premium_order expired {product.slug} {order.id} {order.customer.steam.id}` (unused)
    - On Renew: `exp_premium_order renewed {product.slug} {order.id} {order.customer.steam.id}` (unused)
    - On Refund: `exp_premium_order refunded {product.slug} {order.id} {order.customer.steam.id}`
    - On Cancel: `exp_premium_order canceled {product.slug} {order.id} {order.customer.steam.id}`

    Ensure to set `Execute when online` for all commands and set them to execute on all or the Experiment Game Server.
