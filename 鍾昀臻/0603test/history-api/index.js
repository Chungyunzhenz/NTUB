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

app.post('/search_history', (req, res) => {
  const keyword = req.body.keyword;
  const query = `
    SELECT * FROM history_records 
    WHERE academic_year LIKE ? 
    OR period LIKE ?
    OR date LIKE ?
    OR course_name LIKE ?
    OR leave_reason LIKE ?
    OR leave_form LIKE ?
    OR course_selection_form LIKE ?
    OR description LIKE ?
    OR title LIKE ?`;
  const keywordWithWildcards = `%${keyword}%`;

  connection.query(query, Array(9).fill(keywordWithWildcards), (error, results) => {
    if (error) {
      console.error('Error executing query:', error);
      res.status(500).send('Error executing query');
      return;
    }
    res.json(results);
  });
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
