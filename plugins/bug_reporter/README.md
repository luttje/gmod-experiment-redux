# 🪲 Bug Reporter Plugin

This plugin allows players to report bugs directly from the game, enhancing the feedback loop for developers. Bugs are sent in as GitHub issues, making it easier to track and resolve them.

## Getting Started

1. Create an organization to host the bug reports.

2. add the bot user that will report issues to that organization.

3. Go to <https://github.com/settings/personal-access-tokens/new>

4. Fill in the form as follows:

    * Choose an expiration date that suits your needs.

    * Under `Resource Owner` select the organization you created in step 1.

    * Under `Repository Access` select `All repositories`.

    * Under `Permissions` click `Add permissions`, search `Issues` and select it.

    * Change the `Access` to `Read and write`.

    * Click `Generate token`, confirm and then copy the token.

5. Grant access from an owner account in the organization [here](https://github.com/organizations/experiment-games/settings/personal-access-token-requests)

6. Copy the `.env.example` file to `.env` and paste your token in the `PERSONAL_ACCESS_TOKEN` field.
