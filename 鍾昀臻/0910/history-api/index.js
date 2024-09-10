const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = 4000;

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

app.get('/history', (req, res) => {
  const query = 'SELECT * FROM history_records';
  connection.query(query, (error, results) => {
    if (error) {
      console.error('Error executing query:', error);
      res.status(500).send('Server error');
      return;
    }
    res.json(results);
  });
});

app.post('/filter_history', (req, res) => {
  const keyword = req.body.keyword;
  const searchType = req.body.type;

  // 验证和处理输入的 searchType
  const validColumns = ['academic_year', 'period', 'date', 'course_name', 'leave_reason', 'description', 'title'];
  if (!validColumns.includes(searchType)) {
    return res.status(400).send('Invalid search type');
  }

  // 构建查询语句，移除了 leave_form 列的查询
  const query = `SELECT * FROM history_records WHERE ${searchType} LIKE ?`;

  // 生成通配符关键字
  const keywordWithWildcards = `%${keyword}%`;

  connection.query(
    query,
    [keywordWithWildcards],
    (error, results) => {
      if (error) {
        console.error('Error executing query:', error); // 输出详细的错误信息到控制台
        res.status(500).send('Error executing query');
        return;
      }
      res.json(results);
    }
  );
});


app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
