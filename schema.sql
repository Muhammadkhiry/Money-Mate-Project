use Billing;

CREATE TABLE User_table(
    userid INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(30),
    user_password VARCHAR(60),
    email VARCHAR(40),
    phone VARCHAR(15),
    user_address VARCHAR(60),
    user_type VARCHAR(10),

	CONSTRAINT unique_username UNIQUE (username),
	CONSTRAINT unique_email UNIQUE (email),
	CONSTRAINT unique_phone UNIQUE (phone)
);

create table customer(
	customer_id int primary key,
	gender char(1),
	salary int,

	constraint customer_fk foreign key (customer_id)
	references User_table(userid)
);

create table company(
	company_id int primary key,
	com_type varchar(15),
	registration_number varchar(15),

	constraint company_fk foreign key(company_id)
	references User_table(userid)

);
create table bill(
    bill_id INT IDENTITY(1,1) PRIMARY KEY,
    bill_amount DECIMAL(10,2),
    bill_status VARCHAR(10) DEFAULT 'unpaid',
    created_at DATETIME DEFAULT GETDATE(),
    paid_at DATETIME NULL,
    customer_id int,
    company_id int,

    constraint bill_customer_fk foreign key (customer_id)
    references customer(customer_id),

    constraint bill_company_fk foreign key (company_id)
    references company(company_id)
);


-- Drop all data + reset IDs + add sample data
DELETE FROM bill;
DELETE FROM customer;
DELETE FROM company;
DELETE FROM User_table;
DBCC CHECKIDENT ('User_table', RESEED, 0);
DBCC CHECKIDENT ('bill', RESEED, 0);
GO

INSERT INTO User_table (username, user_password, email, phone, user_address, user_type) VALUES
('Ahmed Ali', '$2b$12$ThisIsHashedPassword123', 'ahmed@gmail.com', '01001234567', 'Cairo', 'customer'),
('Sara Mohamed', '$2b$12$ThisIsHashedPassword123', 'sara@yahoo.com', '01102345678', 'Alexandria', 'customer'),
('Mohamed Hassan', '$2b$12$ThisIsHashedPassword123', 'mohamed@outlook.com', '01203456789', 'Mansoura', 'customer'),
('Fatma Ahmed', '$2b$12$ThisIsHashedPassword123', 'fatma@gmail.com', '01504567890', 'Tanta', 'customer'),
('Omar Khaled', '$2b$12$ThisIsHashedPassword123', 'omar@hotmail.com', '01009876543', 'Giza', 'customer'),
('Nour Eldin', '$2b$12$ThisIsHashedPassword123', 'nour@gmail.com', '01111222333', 'Suez', 'customer'),
('Layla Mostafa', '$2b$12$ThisIsHashedPassword123', 'layla@yahoo.com', '01222333444', 'Ismailia', 'customer'),

-- Companies (unique phones!)
('Vodafone Egypt', '$2b$12$ThisIsHashedPassword123', 'contact@vodafone.eg', '01000123456', 'Smart Village', 'company'),
('Etisalat Misr', '$2b$12$ThisIsHashedPassword123', 'info@etisalat.eg', '01100123456', 'Cairo', 'company'),
('Orange Egypt', '$2b$12$ThisIsHashedPassword123', 'support@orange.eg', '01200123456', 'Giza', 'company'),
('WE Telecom', '$2b$12$ThisIsHashedPassword123', 'we@te.eg', '01500123456', 'Cairo', 'company'),
('Egypt Electricity', '$2b$12$ThisIsHashedPassword123', 'info@electricity.eg', '121', 'Cairo', 'company'),
('Cairo Water Company', '$2b$12$ThisIsHashedPassword123', 'contact@water.eg', '19177', 'Cairo', 'company'),
('Gas Company', '$2b$12$ThisIsHashedPassword123', 'gas@egypt.com', '129', 'Cairo', 'company'),
('National Bank', '$2b$12$ThisIsHashedPassword123', 'support@nbe.eg', '16664', 'Cairo', 'company');
GO

INSERT INTO customer (customer_id, gender, salary)
SELECT userid, 
       CASE WHEN username LIKE '%Ahmed%' OR username LIKE '%Mohamed%' OR username LIKE '%Omar%' THEN 'M' ELSE 'F' END,
       12000 + (ABS(CHECKSUM(NEWID())) % 30000)
FROM User_table WHERE user_type = 'customer';
GO

INSERT INTO company (company_id, com_type, registration_number)
SELECT userid, 
       CASE 
         WHEN username LIKE '%Voda%' OR username LIKE '%Etisalat%' OR username LIKE '%Orange%' OR username LIKE '%WE%' THEN 'Telecom'
         WHEN username LIKE '%Electric%' OR username LIKE '%Water%' OR username LIKE '%Gas%' THEN 'Utility'
         ELSE 'Bank'
       END,
       'REG' + RIGHT('000' + CAST(userid AS VARCHAR), 4)
FROM User_table WHERE user_type = 'company';
GO

DECLARE @i INT = 1;
WHILE @i <= 40
BEGIN
    INSERT INTO bill (company_id, customer_id, bill_amount, bill_status)
    SELECT TOP 1
        co.company_id,
        cu.customer_id,
        ROUND(50 + (RAND() * 950), 2),  -- Random amount between 50 and 1000
        CASE WHEN @i % 3 = 0 THEN 'paid' ELSE 'unpaid' END
    FROM company co
    CROSS JOIN customer cu
    ORDER BY NEWID();

    SET @i = @i + 1;
END
GO

UPDATE bill 
SET paid_at = DATEADD(day, -ABS(CHECKSUM(NEWID())) % 30, GETDATE())
WHERE bill_status = 'paid';
GO

PRINT 'SUCCESS! 15+ users and 40+ bills added with NO duplicate errors!'