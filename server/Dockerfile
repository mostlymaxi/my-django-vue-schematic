FROM python:3.9.12-alpine

RUN pip install --upgrade pip

COPY ./requirements.txt .
RUN pip install -r requirements.txt

COPY . .

ENTRYPOINT [ "sh", "/entrypoint.sh" ]