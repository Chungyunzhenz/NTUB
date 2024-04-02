import torch
from torch import nn
from torchvision.models import vit_b_16  # 使用預訓練的Vision Transformer模型
from torchvision.transforms import Compose, Resize, Normalize, ToTensor
from torch.utils.data import DataLoader, Dataset
from PIL import Image

class CustomImageDataset(Dataset):
    """一個自定義的圖像數據集類，用於加載包含和不包含表格的圖像"""
    def __init__(self, annotations_file, img_dir, transform=None):
        self.img_labels = pd.read_csv(annotations_file)
        self.img_dir = img_dir
        self.transform = transform

    def __len__(self):
        return len(self.img_labels)

    def __getitem__(self, idx):
        img_path = os.path.join(self.img_dir, self.img_labels.iloc[idx, 0])
        image = Image.open(img_path)
        label = self.img_labels.iloc[idx, 1]
        if self.transform:
            image = self.transform(image)
        return image, label

# 定義圖像轉換
transform = Compose([
    Resize((224, 224)),
    ToTensor(),
    Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])

# 加載訓練數據集和測試數據集
train_dataset = CustomImageDataset(annotations_file='train_labels.csv', img_dir='train', transform=transform)
test_dataset = CustomImageDataset(annotations_file='test_labels.csv', img_dir='test', transform=transform)

train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True)
test_loader = DataLoader(test_dataset, batch_size=32, shuffle=False)

# 定義模型
class ViTForTableClassification(nn.Module):
    def __init__(self, num_classes=4):
        super(ViTForTableClassification, self).__init__()
        self.vit = vit_b_16(pretrained=True)
        self.classifier = nn.Linear(self.vit.heads[0].in_features, num_classes)

    def forward(self, x):
        x = self.vit(x)
        x = self.classifier(x)
        return x

# 實例化模型並準備訓練
model = ViTForTableClassification()
criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters(), lr=1e-4)

# 訓練模型
def train(model, criterion, optimizer, train_loader, epochs=10):
    model.train()
    for epoch in range(epochs):
        for images, labels in train_loader:
            optimizer.zero_grad()
            outputs = model(images)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
        print(f'Epoch {epoch+1}, Loss: {loss.item()}')

# 訓練模型
train(model, criterion, optimizer, train_loader)

# 注意：實際應用中你需要在test_loader上進行模型評估，並調整模型參數以改善性能。
