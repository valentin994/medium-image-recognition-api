# Image Recognition FastAPI

This repository is couple with a medium story to showcase a small and simple example of how to host an image recognition API leveraging FastAPI and torhcvision

## Running the Example
```bash
pip install -r requirements.txt
uvicorn main:app --reload
```
This will spinup a FastAPI server with an "/image/" route where you can supply an image for classifying.