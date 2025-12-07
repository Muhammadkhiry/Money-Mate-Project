require('dotenv').config();

const express = require('express');
const bcrypt = require('bcrypt');
const { getPool, sql } = require('../config/database');

const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRATION = process.env.JWT_EXPIRATION;

const router = express.Router();

// REGISTER
router.post('/register', async (req, res) => {
  const {
    username, password, email, phone, user_address, user_type,
    gender, salary, com_type, registration_number
  } = req.body;

  if (!username || !password || !email || !user_type) {
    return res.status(400).json({ error: 'Required fields missing' });
  }

  try {
    const pool = await getPool();

    // Check duplicates
    const check = await pool.request()
      .input('username', sql.VarChar(30), username)
      .input('email', sql.VarChar(40), email)
      .input('phone', sql.VarChar(15), phone || '')
      .query(`
        SELECT username, email, phone FROM User_table
        WHERE username = @username OR email = @email OR phone = @phone
      `);

    if (check.recordset.length > 0) {
      const e = check.recordset[0];
      if (e.username === username) return res.status(400).json({ error: 'Username taken' });
      if (e.email === email) return res.status(400).json({ error: 'Email already exists' });
      if (e.phone === phone) return res.status(400).json({ error: 'Phone already exists' });
    }

    const hash = await bcrypt.hash(password, 12);

    const transaction = new sql.Transaction(pool);
    await transaction.begin();

    try {
      const userResult = await transaction.request()
        .input('username', sql.VarChar(30), username)
        .input('user_password', sql.VarChar(60), hash)
        .input('email', sql.VarChar(40), email)
        .input('phone', sql.VarChar(15), phone || null)
        .input('user_address', sql.VarChar(60), user_address || null)
        .input('user_type', sql.VarChar(10), user_type)
        .query(`
          INSERT INTO User_table (username, user_password, email, phone, user_address, user_type)
          VALUES (@username, @user_password, @email, @phone, @user_address, @user_type);
          SELECT SCOPE_IDENTITY() AS userId;
        `);

      const userId = userResult.recordset[0].userId;

      if (user_type === 'customer') {
        await transaction.request()
          .input('customer_id', sql.Int, userId)
          .input('gender', sql.Char(1), gender || 'O')
          .input('salary', sql.Int, salary || 0)
          .query(`INSERT INTO customer (customer_id, gender, salary) VALUES (@customer_id, @gender, @salary)`);
      } else if (user_type === 'company') {
        await transaction.request()
          .input('company_id', sql.Int, userId)
          .input('com_type', sql.VarChar(15), com_type || null)
          .input('registration_number', sql.VarChar(15), registration_number || null)
          .query(`INSERT INTO company (company_id, com_type, registration_number) VALUES (@company_id, @com_type, @registration_number)`);
      }

      await transaction.commit();
      res.status(201).json({ message: 'Registered successfully' });

    } catch (txErr) {
      await transaction.rollback();
      throw txErr;
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Registration failed' });
  }
});

// LOGIN
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'Email and password required' });

  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('email', sql.VarChar(40), email)
      .query(`
        SELECT userid, username, user_password, user_type
        FROM User_table WHERE email = @email
      `);

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = result.recordset[0];
    const match = await bcrypt.compare(password, user.user_password);

    if (!match) return res.status(401).json({ error: 'Invalid password' });

    // Generate JWT token
    const token = jwt.sign(
      { userid: user.userid, username: user.username, email, user_type: user.user_type },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRATION }
    );

    res.json({
      message: 'Login successful',
      token,
      user: {
        userid: user.userid,
        username: user.username,
        email,
        user_type: user.user_type
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Login failed' });
  }
});

module.exports = router;