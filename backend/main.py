from fastapi import FastAPI
import requests

from config import *

app = FastAPI()


@app.get("/")
def home():
    return {
        "project": "Kafka Infrastructure Platform",
        "status": "running"
    }


@app.post("/deploy")
def deploy():

    crumb_response = requests.get(
        f"{JENKINS_URL}/crumbIssuer/api/json",
        auth=(JENKINS_USER, JENKINS_TOKEN)
    )

    if crumb_response.status_code != 200:
        return {
            "status": "error",
            "message": "Unable to fetch Jenkins crumb",
            "response": crumb_response.text
        }

    crumb_data = crumb_response.json()

    headers = {
        crumb_data["crumbRequestField"]: crumb_data["crumb"]
    }

    response = requests.post(
        f"{JENKINS_URL}/job/{JOB_NAME}/build",
        auth=(JENKINS_USER, JENKINS_TOKEN),
        headers=headers
    )

    return {
        "status": "triggered",
        "jenkins_status": response.status_code
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }
