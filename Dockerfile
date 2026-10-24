# 用 Node 22 的輕量版當基底
FROM node:22-alpine
WORKDIR /app

# 先複製套件清單再安裝，程式碼改了但套件沒變時，可以沿用快取
COPY package*.json ./
RUN npm ci

COPY . .
EXPOSE 8000

# 直接用 tsx 執行 TypeScript，跟本機 npm run dev 的方式一樣
CMD ["npx", "tsx", "src/index.ts"]
