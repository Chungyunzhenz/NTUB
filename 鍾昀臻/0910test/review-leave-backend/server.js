const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(bodyParser.json());
app.use(cors());

let db;

function handleDisconnect() {
    db = mysql.createConnection({
        host: '140.131.114.242',
        user: 'ntub_finalProject',
        password: 'Nttub$Eas0nZct',
        database: '113-Ntub_113205DB',
    });

    db.connect((err) => {
        if (err) {
            console.error('Error connecting to MySQL:', err);
            setTimeout(handleDisconnect, 2000); // 2秒后重新连接
        } else {
            console.log('MySQL Connected...');
        }
    });

    db.on('error', (err) => {
        console.error('MySQL error:', err);
        if (err.code === 'PROTOCOL_CONNECTION_LOST') {
            handleDisconnect(); // 重新连接
        } else {
            throw err;
        }
    });
}

handleDisconnect();

// 新增一个检查数据库连接状态的中间件
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

// 在每个请求前检查数据库连接状态
app.use(checkDbConnection);

// API: 獲取請假單或選課單根據不同狀態和類型
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

// API: 更新審核狀態，包含退回原因和操作角色
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

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
