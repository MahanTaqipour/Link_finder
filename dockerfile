FROM python:3.9
RUN apt-get update && apt-get install -y google-chrome-stable
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
RUN playwright install
CMD ["streamlit", "run", "app.py", "--server.port=8501"]