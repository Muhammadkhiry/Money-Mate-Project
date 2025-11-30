require('dotenv').config();

const express = require('express');
const sql = require('mssql');
const cors = require('cors');
const bodyParser = require('body-parser');
const bcrypt = require('bcrypt');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// SQL Server configuration
const config = {
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  server: process.env.DB_SERVER,
  database: process.env.DB_NAME,
  options: {
    instanceName: process.env.DB_INSTANCE,
    trustServerCertificate: true,
    encrypt: false
  }
};

sql.connect(config)
  .then(pool => {
    console.log("Connected to SQL Server");
  })
  .catch(err => {
    console.error("SQL Connection Error:", err);
  });

// -------------------------------------
// COMPANY VIEW ALL THEIR BILLS
// -------------------------------------
app.get('/bills/company/:id', async (req, res) => {
  const company_id = req.params.id;

  try {
    const pool = await sql.connect(config);
    const result = await pool.request()
      .input('company_id', sql.Int, company_id)
      .query(`
        SELECT 
          b.bill_id, 
          b.bill_amount, 
          b.bill_status,
          c.customer_id,
          u.username AS customer_name
        FROM bill b
        JOIN customer c ON b.customer_id = c.customer_id
        JOIN User_table u ON c.customer_id = u.userid
        WHERE b.company_id = @company_id;
      `);

    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});



// -------------------------------------
// CUSTOMER VIEW ALL BILLS
// -------------------------------------
app.get('/bills/customer/:id', async (req, res) => {
  const customer_id = req.params.id;

  try {
    const pool = await sql.connect(config);
    const result = await pool.request()
      .input('customer_id', sql.Int, customer_id)
      .query(`
        SELECT 
          b.bill_id, 
          b.bill_amount, 
          b.bill_status,
          c.company_id,
          u.username AS company_name
        FROM bill b
        JOIN company c ON b.company_id = c.company_id
        JOIN User_table u ON c.company_id = u.userid
        WHERE b.customer_id = @customer_id;
      `);

    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// -------------------------------------
// Filters for bills / IDK if we need this 
// -------------------------------------

// GET bills for a customer with optional status filter
app.get('/bills/customer/:id', async (req, res) => {
  const customer_id = req.params.id;
  const status = req.query.status; // paid, unpaid, or undefined (all)

  try {
    const pool = await sql.connect(config);

    let query = `
      SELECT 
        b.bill_id, 
        b.bill_amount, 
        b.bill_status,
        u.username AS company_name
      FROM bill b
      JOIN company c ON b.company_id = c.company_id
      JOIN User_table u ON c.company_id = u.userid
      WHERE b.customer_id = @customer_id
    `;

    if (status && (status === 'paid' || status === 'unpaid')) {
      query += ` AND b.bill_status = @status`;
    }

    const result = await pool.request()
      .input('customer_id', sql.Int, customer_id)
      .input('status', sql.VarChar, status || '')
      .query(query);

    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET bills for a company with optional status filter
app.get('/bills/company/:id', async (req, res) => {
  const company_id = req.params.id;
  const status = req.query.status; // paid, unpaid, or undefined (all)

  try {
    const pool = await sql.connect(config);

    let query = `
      SELECT 
        b.bill_id, 
        b.bill_amount, 
        b.bill_status,
        u.username AS customer_name
      FROM bill b
      JOIN customer c ON b.customer_id = c.customer_id
      JOIN User_table u ON c.customer_id = u.userid
      WHERE b.company_id = @company_id
    `;

    if (status && (status === 'paid' || status === 'unpaid')) {
      query += ` AND b.bill_status = @status`;
    }

    const result = await pool.request()
      .input('company_id', sql.Int, company_id)
      .input('status', sql.VarChar, status || '')
      .query(query);

    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


app.listen(3000, () => { console.log('Server running on port 3000'); });