FROM python:3.13

WORKDIR /backend

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app/backend/ .

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

# docker build -t agroboard .