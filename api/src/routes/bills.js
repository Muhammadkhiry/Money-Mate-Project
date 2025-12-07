const express = require('express');
const { getPool, sql } = require('../config/database');
const verifyToken = require('../middleware/authMiddleware');


const router = express.Router();

// Company adds bill
router.post('/add', verifyToken, async (req, res) => {
  const { customer_email, bill_amount } = req.body;
  const company_id = req.user.userid; // secure: company ID from token
  if (!company_id || !customer_email || !bill_amount) {
    return res.status(400).json({ error: 'Missing fields' });
  }

  try {
    const pool = await getPool();

    // Find the customer ID by email
    const userResult = await pool.request()
      .input('email', sql.VarChar(40), customer_email)
      .query(`
        SELECT userid FROM User_table
        WHERE email = @email
      `);

    if (userResult.recordset.length === 0) {
      return res.status(404).json({ error: 'Customer not found' });
    }  
    const customer_id = userResult.recordset[0].userid;
    
    // add bill
    const result = await pool.request()
      .input('company_id', sql.Int, company_id)
      .input('customer_id', sql.Int, customer_id)
      .input('bill_amount', sql.Decimal(10, 2), bill_amount)
      .query(`
        INSERT INTO bill (company_id, customer_id, bill_amount, bill_status)
        OUTPUT INSERTED.bill_id
        VALUES (@company_id, @customer_id, @bill_amount, 'unpaid')
      `);

    res.status(201).json({
      message: 'Bill created',
      bill_id: result.recordset[0].bill_id
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Customer pays bill
router.patch('/:billId/pay', verifyToken, async (req, res) => {
  const { billId } = req.params;

  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('bill_id', sql.Int, billId)
      .query(`
        UPDATE bill SET bill_status = 'paid', paid_at = GETDATE()
        WHERE bill_id = @bill_id AND bill_status = 'unpaid'
      `);

    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({ error: 'Bill not found or already paid' });
    }

    res.json({ message: 'Bill paid successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Company: View all bills
router.get('/company', verifyToken, async (req, res) => {
  const id = req.user.userid; // secure: company ID from token
  const { status } = req.query;

  try {
    const pool = await getPool();
    let query = `
      SELECT b.bill_id, b.bill_amount, b.bill_status, b.created_at,
             u.username AS customer_name
      FROM bill b
      JOIN customer c ON b.customer_id = c.customer_id
      JOIN User_table u ON c.customer_id = u.userid
      WHERE b.company_id = @company_id
    `;
    const request = pool.request().input('company_id', sql.Int, id);

    if (status === 'paid' || status === 'unpaid') {
      query += ` AND b.bill_status = @status`;
      request.input('status', sql.VarChar(10), status);
    }

    query += ` ORDER BY b.created_at DESC`;

    const result = await request.query(query);
    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Customer: View all bills
router.get('/customer', verifyToken, async (req, res) => {
  const id = req.user.userid; // secure: customer ID from token
  const { status } = req.query;

  try {
    const pool = await getPool();
    let query = `
      SELECT b.bill_id, b.bill_amount, b.bill_status, b.created_at,
             u.username AS company_name
      FROM bill b
      JOIN company c ON b.company_id = c.company_id
      JOIN User_table u ON c.company_id = u.userid
      WHERE b.customer_id = @customer_id
    `;
    const request = pool.request().input('customer_id', sql.Int, id);

    if (status === 'paid' || status === 'unpaid') {
      query += ` AND b.bill_status = @status`;
      request.input('status', sql.VarChar(10), status);
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