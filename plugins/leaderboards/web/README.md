# 🕹 Experiment Leaderboards: 'Heroes of the Epoch'

Backend for the Experiment gamemode to communicate metrics to. This project will then display the metrics on the leaderboards. The leaderboards are named 'Heroes of the Epoch'.

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

6. Link the storage folder

    ```bash
    php artisan storage:link
    ```

7. Compile the assets

    ```bash
    npm run dev
    ```

8. Start the development server

    ```bash
    php artisan serve
    ```
