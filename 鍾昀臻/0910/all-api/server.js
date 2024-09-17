const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = 4000; // 設定伺服器端口

app.use(cors()); // 允許所有請求
app.use(bodyParser.json());

const dbConfig = {
  host: '140.131.114.242',
  user: 'ntub_finalProject',
  password: 'Nttub$Eas0nZct',
  database: '113-Ntub_113205DB',
};

let db;

// 自動重連 MySQL 資料庫
function handleDisconnect() {
  db = mysql.createConnection(dbConfig);

  db.connect((err) => {
    if (err) {
      console.error('Error connecting to MySQL:', err);
      setTimeout(handleDisconnect, 2000); // 2秒後重新連線
    } else {
      console.log('MySQL Connected...');
    }
  });

  db.on('error', (err) => {
    console.error('MySQL error:', err);
    if (err.code === 'PROTOCOL_CONNECTION_LOST') {
      handleDisconnect(); // 自動重連
    } else {
      throw err;
    }
  });
}

handleDisconnect();

// 檢查資料庫連線的中間件
function checkDbConnection(req, res, next) {
  if (db.state === 'disconnected') {
    console.error('Database is disconnected');
    return res.status(500).json({
      success: false,
      message: 'Database connection lost. Please try again later.',
    });
  }
  next();
}

app.use(checkDbConnection);

// API 1: 獲取歷史紀錄
app.get('/history', (req, res) => {
  const query = 'SELECT * FROM history_records';
  db.query(query, (error, results) => {
    if (error) {
      console.error('Error executing query:', error);
      return res.status(500).send('Server error');
    }
    res.json(results);
  });
});

// API 2: 根據條件篩選歷史紀錄
app.post('/filter_history', (req, res) => {
  const keyword = req.body.keyword;
  const searchType = req.body.type;

  const validColumns = ['academic_year', 'period', 'date', 'course_name', 'leave_reason', 'description', 'title'];
  if (!validColumns.includes(searchType)) {
    return res.status(400).send('Invalid search type');
  }

  const query = `SELECT * FROM history_records WHERE ${searchType} LIKE ?`;
  const keywordWithWildcards = `%${keyword}%`;

  db.query(query, [keywordWithWildcards], (error, results) => {
    if (error) {
      console.error('Error executing query:', error);
      return res.status(500).send('Error executing query');
    }
    res.json(results);
  });
});

// API 3: 獲取請假單或選課單根據不同狀態和類型
app.get('/getLeaveRequests', (req, res) => {
  const status = req.query.status;
  const title = req.query.title;
  const sql = "SELECT * FROM ReviewProgress WHERE TRIM(review_status) = ? AND TRIM(title) = ?";

  db.query(sql, [status, title], (err, results) => {
    if (err) {
      console.error('Error fetching requests:', err);
      return res.status(500).json({
        success: false,
        message: 'Error fetching requests',
        error: err.message,
      });
    }
    console.log(`${title} requests fetched successfully. Count:`, results.length);
    return res.json(results);
  });
});

// API 4: 更新審核狀態，包含退回原因和操作角色
app.post('/updateReviewStatus', (req, res) => {
  const { id, status, return_reason, returned_by } = req.body;

  if (!id || !status) {
    return res.status(400).json({
      success: false,
      message: 'ID and status are required',
    });
  }

  const sql = `
    UPDATE ReviewProgress 
    SET review_status = ?, review_date = NOW(), return_reason = ?, returned_by = ? 
    WHERE id = ?`;

  db.query(sql, [status, return_reason, returned_by, id], (err, result) => {
    if (err) {
      console.error('Error updating review status:', err);
      return res.status(500).json({
        success: false,
        message: 'Error updating review status',
        error: err.message,
      });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: `No record found with ID ${id}`,
      });
    }

    console.log(`Review status for ID ${id} updated to ${status}`);
    return res.json({
      success: true,
      message: `Review status updated successfully for ID ${id}`,
      affectedRows: result.affectedRows
    });
  });
});

// 啟動伺服器
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
