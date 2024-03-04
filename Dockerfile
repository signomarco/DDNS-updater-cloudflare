# Container that run the change-record.sh script and then exit
FROM alpine:3.7
COPY change-record.sh /change-record.sh
RUN chmod +x /change-record.sh
ENTRYPOINT [ "sh", "/change-record.sh" ]