const express = require('express');
const { getPool, sql } = require('../config/database');
const verifyToken = require('../middleware/authMiddleware');


const router = express.Router();

// company stats
router.get('/company/:period', verifyToken, async (req, res) => {
    const company_id = req.user.userid;
    const period = req.params.period;

    let startDateQuery;

    switch (period) {
        case 'day': startDateQuery = "DATEADD(day, -1, GETDATE())"; break;
        case 'week': startDateQuery = "DATEADD(week, -1, GETDATE())"; break;
        case 'month': startDateQuery = "DATEADD(month, -1, GETDATE())"; break;
        case 'year': startDateQuery = "DATEADD(year, -1, GETDATE())"; break;
        default: return res.status(400).json({ error: "Invalid period" });
    }

    try {
        const pool = await getPool();

        const result = await pool.request()
            .input('company_id', sql.Int, company_id)
            .query(`
        SELECT 
          SUM(CASE WHEN bill_status = 'paid' THEN bill_amount ELSE 0 END) AS total_paid,
          SUM(CASE WHEN bill_status = 'unpaid' THEN bill_amount ELSE 0 END) AS total_unpaid
        FROM bill
        WHERE company_id = @company_id
        AND created_at >= ${startDateQuery}
      `);

        res.json(result.recordset[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});


// customer stats
router.get('/customer/:period', verifyToken, async (req, res) => {
    const customer_id = req.user.userid;
    const period = req.params.period;

    let startDateQuery;

    switch (period) {
        case 'day': startDateQuery = "DATEADD(day, -1, GETDATE())"; break;
        case 'week': startDateQuery = "DATEADD(week, -1, GETDATE())"; break;
        case 'month': startDateQuery = "DATEADD(month, -1, GETDATE())"; break;
        case 'year': startDateQuery = "DATEADD(year, -1, GETDATE())"; break;
        default: return res.status(400).json({ error: "Invalid period" });
    }

    try {
        const pool = await getPool();

        const result = await pool.request()
            .input('customer_id', sql.Int, customer_id)
            .query(`
      SELECT 
        c.salary - ISNULL((SELECT SUM(bill_amount) FROM bill WHERE customer_id = c.customer_id AND bill_status = 'paid'), 0) AS total_balance,
        SUM(CASE WHEN b.bill_status = 'paid' THEN b.bill_amount ELSE 0 END) AS total_paid,
        SUM(CASE WHEN b.bill_status = 'unpaid' THEN b.bill_amount ELSE 0 END) AS total_unpaid
      FROM customer c
      LEFT JOIN bill b ON c.customer_id = b.customer_id
      WHERE c.customer_id = @customer_id
      AND (b.created_at >= ${startDateQuery} OR b.created_at IS NULL)
      GROUP BY c.customer_id, c.salary
    `);


        res.json(result.recordset[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;