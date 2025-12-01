const express = require('express');
const { getPool, sql } = require('../config/database');

const router = express.Router();

// Search company bills
router.get('/company/:id/bills', async (req, res) => {
  const companyId = req.params.id;
  const { name, status } = req.query;

  try {
    const pool = await getPool();
    let query = `
      SELECT b.bill_id, b.bill_amount, b.bill_status,
             u.username AS customer_name
      FROM bill b
      LEFT JOIN customer c ON b.customer_id = c.customer_id
      LEFT JOIN User_table u ON c.customer_id = u.userid
      WHERE b.company_id = @company_id
    `;

    const request = pool.request().input('company_id', sql.Int, companyId);

    if (status && (status === 'paid' || status === 'unpaid')) {
      query += ` AND b.bill_status = @status`;
      request.input('status', sql.VarChar(10), status);
    }
    if (name && name.trim()) {
      query += ` AND u.username LIKE @name`;
      request.input('name', sql.VarChar(100), `%${name.trim()}%`);
    }

    query += ` ORDER BY b.created_at DESC`;

    const result = await request.query(query);
    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Search customer bills
router.get('/customer/:id/bills', async (req, res) => {
  const customerId = req.params.id;
  const { name, status } = req.query;

  try {
    const pool = await getPool();
    let query = `
      SELECT b.bill_id, b.bill_amount, b.bill_status,
             u.username AS company_name
      FROM bill b
      JOIN company c ON b.company_id = c.company_id
      JOIN User_table u ON c.company_id = u.userid
      WHERE b.customer_id = @customer_id
    `;

    const request = pool.request().input('customer_id', sql.Int, customerId);

    if (status && (status === 'paid' || status === 'unpaid')) {
      query += ` AND b.bill_status = @status`;
      request.input('status', sql.VarChar(10), status);
    }
    if (name && name.trim()) {
      query += ` AND u.username LIKE @name`;
      request.input('name', sql.VarChar(100), `%${name.trim()}%`);
    }

    query += ` ORDER BY b.created_at DESC`;

    const result = await request.query(query);
    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;