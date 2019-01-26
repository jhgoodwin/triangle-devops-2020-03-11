ARG IMGBASE
FROM ${IMGBASE}
ENV PYTHONPATH "/app/site:/app/lib"
COPY test.requirements.txt ./
COPY tests tests
COPY *.sh ./
RUN chmod +x *.sh
RUN pip install -r test.requirements.txt

ENTRYPOINT ["/app/run_tests_docker.sh"]