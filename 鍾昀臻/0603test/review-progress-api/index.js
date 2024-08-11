const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = 5000;

app.use(cors());
app.use(bodyParser.json());

const connection = mysql.createConnection({
  host: '140.131.114.242',
  user: 'ntub_finalProject',
  password: 'Nttub$Eas0nZct',
  database: '113-Ntub_113205DB',
});

connection.connect(err => {
  if (err) {
    console.error('Database connection failed:', err.stack);
    return;
  }
  console.log('Connected to database.');
});

// 根據review_status篩選數據
app.get('/review_progress', (req, res) => {
  const reviewStatus = req.query.status;

  // 檢查是否提供了 reviewStatus
  if (!reviewStatus) {
    return res.status(400).send('Missing review status');
  }
  
  const query = `SELECT * FROM ReviewProgress WHERE review_status = ?`;

  connection.query(query, [reviewStatus], (error, results) => {
    if (error) {
      console.error('Error executing query:', error);
      res.status(500).send('Error executing query');
      return;
    }
    res.json(results);
  });
});

// 捕獲所有未處理的路由並返回404錯誤
app.use((req, res) => {
  res.status(404).send('Endpoint not found');
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
