// 讀取 .env 裡的資料庫設定
import 'dotenv/config'
import mysql from 'mysql2/promise'

// 建立 MySQL 連線池，其他檔案 import pool 就能查資料庫
// 帳密放 .env，不要寫死在這
export const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
})