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


// Register endpoint
app.post('/register', async (req, res) => {
  const {
    username,
    password,
    email,
    phone,
    user_address,
    user_type,       
    gender,
    salary,
    com_type,
    registration_number,
  } = req.body;

  try {
    const pool = await sql.connect(config);

    // Check if username/email/phone already exist
    const exists = await pool.request()
      .input('username', sql.VarChar(30), username)
      .input('email', sql.VarChar(40), email)
      .input('phone', sql.VarChar(15), phone)
      .query(`
        SELECT username, email, phone
        FROM User_table
        WHERE username = @username
           OR email = @email
           OR phone = @phone;
      `);

    if (exists.recordset.length > 0) {
      const e = exists.recordset[0];

      if (e.username === username) {
        return res.status(400).json({ error: "Username is already taken" });
      }
      if (e.email === email) {
        return res.status(400).json({ error: "Email already exists" });
      }
      if (e.phone === phone) {
        return res.status(400).json({ error: "Phone number already exists" });
      }
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert into User_table
    const userResult = await pool.request()
      .input('username', sql.VarChar(30), username)
      .input('user_password', sql.VarChar(60), hashedPassword)
      .input('email', sql.VarChar(40), email)
      .input('phone', sql.VarChar(15), phone)
      .input('user_address', sql.VarChar(60), user_address)
      .input('user_type', sql.VarChar(10), user_type)
      .query(`
        INSERT INTO User_table (username, user_password, email, phone, user_address, user_type)
        VALUES (@username, @user_password, @email, @phone, @user_address, @user_type);
        SELECT SCOPE_IDENTITY() AS userId;
      `);

    const userId = userResult.recordset[0].userId;

    // Insert into correct table
    if (user_type === 'customer') {
      await pool.request()
        .input('customer_id', sql.Int, userId)
        .input('gender', sql.Char(1), gender)
        .input('salary', sql.Int, salary)
        .query(`
          INSERT INTO customer (customer_id, gender, salary)
          VALUES (@customer_id, @gender, @salary);
        `);
    } else if (user_type === 'company') {
      await pool.request()
        .input('company_id', sql.Int, userId)
        .input('com_type', sql.VarChar(15), com_type)
        .input('registration_number', sql.VarChar(15), registration_number)
        .query(`
          INSERT INTO company (company_id, com_type, registration_number)
          VALUES (@company_id, @com_type, @registration_number);
        `);
    }

    res.status(201).json({ message: "User registered successfully", userId });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Something went wrong" });
  }
});


// Login endpoint
app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const pool = await sql.connect(config);

    // Check if the user exists
    const userResult = await pool.request()
      .input('email', sql.VarChar(40), email)
      .query(`
        SELECT userid, username, user_password, user_type
        FROM User_table
        WHERE email = @email;
      `);

    if (userResult.recordset.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    const user = userResult.recordset[0];

    // Compare the password with bcrypt
    const isMatch = await bcrypt.compare(password, user.user_password);

    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid password' });
    }

    // Send success response with user info
    res.json({
      message: 'Login successful',
      user: {
        userid: user.userid,
        username: user.username,
        email: email,
        user_type: user.user_type
      }
    });

  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({ error: 'Something went wrong during login' });
  }
});

app.listen(3000, () => { console.log('Server running on port 3000'); });
