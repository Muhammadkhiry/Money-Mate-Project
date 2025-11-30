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
// COMPANY ADDS BILL
// -------------------------------------

app.post('/addBill', async (req, res) => {
  const { company_id, customer_id, bill_amount } = req.body;

  try {
    const pool = await sql.connect(config);

    console.log("Request body:", req.body); // <- check what you are sending
    console.log("SQL config:", config);     // <- check connection settings

    await pool.request()
      .input('company_id', sql.Int, company_id)
      .input('customer_id', sql.Int, customer_id)
      .input('bill_amount', sql.Int, bill_amount)
      .query(`
        INSERT INTO bill (company_id, customer_id, bill_amount, bill_status)
        VALUES (@company_id, @customer_id, @bill_amount, 'unpaid');
      `);

    res.status(201).json({ message: "Bill created successfully" });
  } catch (err) {
    console.error("SQL ERROR:", err);  // <- this will print full SQL error
    res.status(500).json({ error: err.message }); // <- send real error to Postman
  }
});



// -------------------------------------
// CUSTOMER PAYS BILL
// -------------------------------------
app.post('/payBill', async (req, res) => {
  const { bill_id } = req.body;

  try {
    const pool = await sql.connect(config);
    const result = await pool.request()
      .input('bill_id', sql.Int, bill_id)
      .query(`
        UPDATE bill SET bill_status = 'paid'
        WHERE bill_id = @bill_id;
      `);

    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({ message: "Bill not found" });
    }

    res.json({ message: "Bill paid successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Payment failed" });
  }
});


  app.listen(3000, () => { console.log('Server running on port 3000'); });