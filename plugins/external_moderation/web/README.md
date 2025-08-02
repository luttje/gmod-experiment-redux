# 🕹 Experiment External Moderation

Backend for the Experiment gamemode to communicate chat logs to. This project will then allow moderators to view the chat logs and take action on them remotely.

Additionally, this project will allow for automatic flagging of messages that are deemed inappropriate by the system.

## 🛠️ Requirements

- PHP `^8.2`
- Composer
- Node.js `^20.19.0 || >=22.12.0`
- npm

## 🚀 Getting Started

1. Clone the repository

2. Install the dependencies

    ```bash
    composer install
    npm install
    ```

3. Copy the `.env.example` file to `.env` and fill in the necessary details

    ```bash
    cp .env.example .env
    ```

4. Generate a new application key

    ```bash
    php artisan key:generate
    ```

5. Run the migrations

    ```bash
    php artisan migrate:fresh --seed
    ```

6. Compile the assets

    ```bash
    npm run dev
    ```

7. Start the development server

    ```bash
    php artisan serve
    ```

## 🔧 Production

Don't forget to setup the job worker and queue system for production use. You can create a Systemd Service for Queue Worker.

```bash
# Create a new service file
sudo nano /etc/systemd/system/experiment-queue-worker.service
```

And add the following content:

```ini
[Unit]
Description=Experiment Queue Worker
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
Restart=always
RestartSec=5
ExecStart=/usr/bin/php /srv/experiment-redux/plugins/external_moderation/web/artisan queue:work --sleep=3 --tries=3 --max-time=3600
WorkingDirectory=/srv/experiment-redux/plugins/external_moderation/web
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=experiment-queue-worker

[Install]
WantedBy=multi-user.target
```

**Make sure to replace `/srv/experiment-redux/plugins/external_moderation/web/artisan` with the actual path to your Project Laravel Artisan file.**

Then enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable experiment-queue-worker
sudo systemctl start experiment-queue-worker

# Check status
sudo systemctl status experiment-queue-worker
```
