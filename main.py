"""Code for medium article"""
from io import BytesIO

from fastapi import FastAPI, UploadFile
from PIL import Image
from torchvision.models import ResNet50_Weights, resnet50

weights = ResNet50_Weights.DEFAULT
model = resnet50(weights=weights)
model.eval()

app = FastAPI()


@app.post("/image/")
async def predict_image_class_endpoint(file: UploadFile):
    preprocess = weights.transforms(antialias=True)
    content = await file.read()
    img = Image.open(BytesIO(content))
    batch = preprocess(img).unsqueeze(0)
    prediction = model(batch).squeeze(0).softmax(0)
    class_id = prediction.argmax().item()
    score = prediction[class_id].item()
    category_name = weights.meta["categories"][class_id]
    return {"message": f"{category_name} - {100 * score:.1f}%"}
