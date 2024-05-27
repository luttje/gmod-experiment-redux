FROM node:latest as builder

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install

COPY . .

# Final base image
FROM mycroftai/mimic3

USER root

RUN mkdir -p /var/cache/apt/archives/partial && \
    chmod -R 755 /var/cache/apt && \
    mkdir -p /var/cache/apt/amd64/archives/partial && \
    chmod -R 755 /var/cache/apt/amd64 && \
    mkdir -p /var/cache/apt/archives/amd64/partial && \
    chmod -R 755 /var/cache/apt/archives/amd64 && \
    apt-get update && apt-get install -yq wget xz-utils nodejs npm

# Copy the Node.js application files from the builder stage
COPY --from=builder /usr/src/app /home/mimic3/server

RUN wget https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz

RUN tar -xvf ffmpeg-git-amd64-static.tar.xz && \
    FOLDER_NAME=$(tar -tf ffmpeg-git-amd64-static.tar.xz | head -n 1 | cut -f1 -d"/") && \
    mv $FOLDER_NAME/ffmpeg /usr/bin/ffmpeg && \
    mv $FOLDER_NAME/ffprobe /usr/bin/ffprobe && \
    chmod +x /usr/bin/ffmpeg && \
    chmod +x /usr/bin/ffprobe

RUN rm -rf ffmpeg-git-amd64-static.tar.xz

COPY ./init-voice-gen.sh /home/mimic3/app/init-voice-gen.sh

EXPOSE 3000

WORKDIR /home/mimic3/server

RUN npm install

ENTRYPOINT ["node", "server.js"]