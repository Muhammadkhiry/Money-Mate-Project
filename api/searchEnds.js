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
//  Search 'Like'
// -------------------------------------

// Search bills for a company by customer name and status
app.get('/bills/company/:id/search', async (req, res) => {
  const company_id = parseInt(req.params.id, 10);
  let { name, status } = req.query;

  try {
    const pool = await sql.connect(config);

    let query = `
      SELECT 
        b.bill_id,
        b.bill_amount,
        b.bill_status,
        u.username AS customer_name
      FROM bill b
      LEFT JOIN customer c ON b.customer_id = c.customer_id
      LEFT JOIN User_table u ON c.customer_id = u.userid
      WHERE b.company_id = @company_id
    `;

    const request = pool.request().input('company_id', sql.Int, company_id);


    if (status) {
      status = status.toString().trim().toLowerCase();
      if (status === 'paid' || status === 'unpaid') {
        request.input('status', sql.VarChar(10), status);
        query += ` AND LOWER(b.bill_status) = @status`;
      }
    }

    if (name && name.trim() !== '') {
      request.input('name', sql.VarChar(100), `%${name.trim()}%`);
      query += ` AND u.username LIKE @name`;
    }

    const result = await request.query(query);
    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Search bills for a customer by company name and status
app.get('/bills/customer/:id/search', async (req, res) => {
  const customer_id = req.params.id;
  const { name, status } = req.query;

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

    if (name && name.trim() !== '') {
      query += ` AND u.username LIKE '%' + @name + '%'`;
    }

    const request = pool.request()
      .input('customer_id', sql.Int, customer_id);

    if (status && (status === 'paid' || status === 'unpaid')) {
      request.input('status', sql.VarChar, status);
    }
    if (name && name.trim() !== '') {
      request.input('name', sql.VarChar, name);
    }

    const result = await request.query(query);

    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

app.listen(3000, () => { console.log('Server running on port 3000'); });