# Cloudflare Dynamic Updater

This project is a DDNS (Dynamic DNS) updater for Cloudflare. It automatically updates the A record of a specified zone in your Cloudflare profile with the public IP address of the host machine.

## Features

- Automatically updates the A record of a Cloudflare zone with the public IP address of the host machine.
- Uses Docker for easy management and deployment.

## Prerequisites

Before running this project, make sure you have the following:

- Docker installed on your machine.
- A Cloudflare account with a valid API token.

## Usage

1. Clone this repository to your local machine.
2. Create the `.env` file with your Cloudflare API token and the desired zone information.
3. Build the Docker image by running the following command in the project directory:
    ```
    docker build -t cloudflare-dynamic-updater .
    ```
4. Run the Docker container using the following command:
    ```
    docker run --env-file .env cloudflare-dynamic-updater
    ```
    or
    ```
    docker run -e API_TOKEN=<your_api_token> \
        -e ZONE_IDENTIFIER=<your_zone_identifier> \
        cloudflare-dynamic-updater
    ```

The container will now run and automatically update the A record of the specified zone with the public IP address of the host machine.

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).