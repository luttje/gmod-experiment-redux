# 🕹 Experiment External Moderation

Backend for the Experiment gamemode to communicate chat logs to. This project will then allow moderators to view the chat logs and take action on them remotely.

Additionally, this project will allow for automatic flagging of messages that are deemed inappropriate by the system.

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
